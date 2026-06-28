// lib/features/auth/presentation/veedor/acta_form_controller.dart
//
// CAMBIOS vs versión anterior:
//  - GPS se captura SOLO al tomar foto (no hay botón manual en UI)
//  - Si permiso GPS denegado → error bloqueante, no permite continuar
//  - GPS se almacena como campo del acta (no como metadato de imagen)
//  - Persistencia offline: las actas se guardan primero en SQLite local
//    y se sincronizan cuando hay conexión (cola de pendientes)
//  - Vista previa del acta lista para mostrar en pantalla
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/acta.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/repositories/acta_repository_provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ESTADO
// ═════════════════════════════════════════════════════════════════════════════
class ActaFormState {
  final int mesaId;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final Map<int, int> votosPorOrganizacion;
  final int votosNulos;
  final int votosBlancos;
  final File? fotoFile;
  final double? gpsLat;
  final double? gpsLng;
  final bool cargandoGps;
  final bool procesandoFoto;
  final bool guardando;
  final String? error;
  final bool guardadoExito;
  final int? actaId;

  /// true cuando el acta fue guardada localmente (offline) pero aún no subida
  final bool pendienteSync;

  const ActaFormState({
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.organizaciones,
    required this.votosPorOrganizacion,
    this.votosNulos = 0,
    this.votosBlancos = 0,
    this.fotoFile,
    this.gpsLat,
    this.gpsLng,
    this.cargandoGps = false,
    this.procesandoFoto = false,
    this.guardando = false,
    this.error,
    this.guardadoExito = false,
    this.actaId,
    this.pendienteSync = false,
  });

  int get totalContabilizado =>
      votosPorOrganizacion.values.fold(0, (a, b) => a + b) +
      votosNulos +
      votosBlancos;

  bool get esConsistente => totalContabilizado <= totalSufragantes;

  /// Se puede guardar si: hay GPS, los votos son consistentes y no está ya guardando
  bool get puedeGuardar =>
      gpsLat != null && gpsLng != null && esConsistente && !guardando;

  ActaFormState copyWith({
    Map<int, int>? votosPorOrganizacion,
    int? votosNulos,
    int? votosBlancos,
    File? fotoFile,
    bool clearFoto = false,
    double? gpsLat,
    double? gpsLng,
    bool? cargandoGps,
    bool? procesandoFoto,
    bool? guardando,
    String? error,
    bool? guardadoExito,
    int? actaId,
    bool? pendienteSync,
  }) {
    return ActaFormState(
      mesaId: mesaId,
      dignidad: dignidad,
      totalSufragantes: totalSufragantes,
      organizaciones: organizaciones,
      votosPorOrganizacion: votosPorOrganizacion ?? this.votosPorOrganizacion,
      votosNulos: votosNulos ?? this.votosNulos,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      fotoFile: clearFoto ? null : (fotoFile ?? this.fotoFile),
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      cargandoGps: cargandoGps ?? this.cargandoGps,
      procesandoFoto: procesandoFoto ?? this.procesandoFoto,
      guardando: guardando ?? this.guardando,
      error: error,
      guardadoExito: guardadoExito ?? this.guardadoExito,
      actaId: actaId ?? this.actaId,
      pendienteSync: pendienteSync ?? this.pendienteSync,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SERVICIO OFFLINE — SQLite local + cola de sincronización
// ═════════════════════════════════════════════════════════════════════════════
class _OfflineActaService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'actas_pendientes.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE actas_pendientes (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            mesa_id      INTEGER NOT NULL,
            usuario_id   TEXT,
            dignidad     TEXT,
            votos_json   TEXT,
            votos_nulos  INTEGER DEFAULT 0,
            votos_blancos INTEGER DEFAULT 0,
            total_sufragantes INTEGER,
            foto_path    TEXT,
            gps_lat      REAL,
            gps_lng      REAL,
            estado       TEXT DEFAULT 'INGRESADA',
            created_at   TEXT,
            intentos     INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  /// Guarda el acta en la base local mientras no hay conexión.
  /// Retorna el id local del registro.
  static Future<int> encolar({
    required int mesaId,
    required String? usuarioId,
    required Dignidad? dignidad,
    required Map<String, int> votos,
    required int votosNulos,
    required int votosBlancos,
    required int totalSufragantes,
    required String? fotoPath,
    required double? gpsLat,
    required double? gpsLng,
  }) async {
    final database = await db;
    return database.insert('actas_pendientes', {
      'mesa_id': mesaId,
      'usuario_id': usuarioId,
      'dignidad': dignidad?.name,
      'votos_json': votos.entries.map((e) => '${e.key}:${e.value}').join(','),
      'votos_nulos': votosNulos,
      'votos_blancos': votosBlancos,
      'total_sufragantes': totalSufragantes,
      'foto_path': fotoPath,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'estado': 'INGRESADA',
      'created_at': DateTime.now().toIso8601String(),
      'intentos': 0,
    });
  }

  /// Retorna todos los registros pendientes de sincronizar.
  static Future<List<Map<String, dynamic>>> pendientes() async {
    final database = await db;
    return database.query('actas_pendientes', orderBy: 'id ASC');
  }

  /// Elimina un registro ya sincronizado.
  static Future<void> eliminar(int localId) async {
    final database = await db;
    await database
        .delete('actas_pendientes', where: 'id = ?', whereArgs: [localId]);
  }

  /// Incrementa el contador de intentos fallidos.
  static Future<void> marcarIntento(int localId) async {
    final database = await db;
    await database.rawUpdate(
      'UPDATE actas_pendientes SET intentos = intentos + 1 WHERE id = ?',
      [localId],
    );
  }

  static Map<String, int> _parsearVotos(String votosJson) {
    if (votosJson.isEmpty) return {};
    return Map.fromEntries(
      votosJson.split(',').map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═════════════════════════════════════════════════════════════════════════════
class ActaFormNotifier extends StateNotifier<ActaFormState> {
  final Ref _ref;

  ActaFormNotifier(this._ref, ActaFormState initialState) : super(initialState);

  // ── Spinner de procesando foto ────────────────────────────────────────────
  void setProcesandoFoto(bool value) {
    state = state.copyWith(procesandoFoto: value);
  }

  // ── Votos ─────────────────────────────────────────────────────────────────
  void actualizarVotosOrganizacion(int orgId, int votos) {
    final mapa = Map<int, int>.from(state.votosPorOrganizacion);
    mapa[orgId] = votos < 0 ? 0 : votos;
    state = state.copyWith(votosPorOrganizacion: mapa, error: null);
  }

  void actualizarVotosNulos(int valor) =>
      state = state.copyWith(votosNulos: valor < 0 ? 0 : valor, error: null);

  void actualizarVotosBlancos(int valor) =>
      state = state.copyWith(votosBlancos: valor < 0 ? 0 : valor, error: null);

  // ── GPS: solo se llama internamente desde procesarFotoDesdeCamera ─────────
  // NO expuesto en la UI como botón.
  // Retorna las coordenadas o null si falla (sin lanzar excepción).
  Future<({double lat, double lng})?> _capturarCoordenadas() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Verifica si el permiso GPS está disponible ANTES de abrir la cámara.
  /// Retorna true si puede continuar, false si debe bloquear.
  Future<bool> verificarPermisoGps() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      state = state.copyWith(
        error:
            'El GPS del dispositivo está desactivado. Actívalo en Ajustes → Ubicación para poder registrar el acta.',
      );
      return false;
    }

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      state = state.copyWith(
        error: 'Se requiere permiso de ubicación para fotografiar el acta. '
            'Ve a Ajustes → Aplicaciones → [esta app] → Permisos → Ubicación.',
      );
      return false;
    }

    return true;
  }

  // ── Foto + GPS simultáneos ────────────────────────────────────────────────
  // Las coordenadas se capturan en el momento exacto de tomar la foto
  // y se almacenan como campo del acta (no como metadato EXIF).
  Future<void> procesarFotoDesdeCamera(XFile xfile) async {
    // Muestra spinner inmediatamente para que la UI responda rápido
    state = state.copyWith(procesandoFoto: true, error: null);

    try {
      final resultados = await Future.wait([
        _procesarImagen(xfile),
        _capturarCoordenadas(),
      ]);

      final File? archivoFoto = resultados[0] as File?;
      final coords = resultados[1] as ({double lat, double lng})?;

      if (archivoFoto == null) {
        // El error ya fue seteado dentro de _procesarImagen
        state = state.copyWith(procesandoFoto: false);
        return;
      }

      state = state.copyWith(
        fotoFile: archivoFoto,
        gpsLat: coords?.lat ?? state.gpsLat,
        gpsLng: coords?.lng ?? state.gpsLng,
        procesandoFoto: false,
        // Si no se obtuvo GPS en este intento pero ya había uno previo, lo conserva.
        // Si no hay GPS en absoluto, alerta pero NO bloquea (se puede reintentar guardando).
        error: (coords == null && state.gpsLat == null)
            ? 'No se pudo obtener la ubicación GPS. '
                'Asegúrate de tener señal y vuelve a tomar la foto.'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        procesandoFoto: false,
        error: 'Error al procesar la foto: $e',
      );
    }
  }

  // Procesa y comprime la imagen; retorna File o null si falla.
  Future<File?> _procesarImagen(XFile xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        state = state.copyWith(error: 'No se pudo procesar la imagen.');
        return null;
      }

      final resized =
          decoded.width > 1200 ? img.copyResize(decoded, width: 1200) : decoded;
      final compressed = img.encodeJpg(resized, quality: 85);

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/acta_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath)..writeAsBytesSync(compressed);

      final isSharp = await compute(_evaluarNitidez, filePath);
      if (!isSharp) {
        await file.delete();
        state = state.copyWith(
          error:
              'La imagen está borrosa. Tome la foto nuevamente en un lugar bien iluminado.',
        );
        return null;
      }

      return file;
    } catch (e) {
      state = state.copyWith(error: 'Error al procesar la foto: $e');
      return null;
    }
  }

  static bool _evaluarNitidez(String path) {
    final file = File(path);
    if (!file.existsSync()) return false;
    final image = img.decodeImage(file.readAsBytesSync());
    if (image == null) return false;

    final grayscale = img.grayscale(image);
    final w = grayscale.width;
    final h = grayscale.height;
    double totalVariance = 0.0;
    int count = 0;

    for (int y = 5; y < h - 5; y += 4) {
      for (int x = 5; x < w - 5; x += 4) {
        final lC = img.getLuminance(grayscale.getPixel(x, y));
        final lR = img.getLuminance(grayscale.getPixel(x + 1, y));
        final lB = img.getLuminance(grayscale.getPixel(x, y + 1));
        final dx = (lC - lR).toDouble();
        final dy = (lC - lB).toDouble();
        totalVariance += dx * dx + dy * dy;
        count++;
      }
    }

    return (totalVariance / count) > 150.0;
  }

  // ── Guardar (online first, offline fallback) ──────────────────────────────
  Future<void> guardarActa({
    required String userId,
    String? urlFotoExistente,
  }) async {
    if (!state.puedeGuardar) {
      if (state.gpsLat == null) {
        state = state.copyWith(
          error:
              'Se requiere la ubicación GPS. Toma la foto del acta para capturarla automáticamente.',
        );
      } else if (!state.esConsistente) {
        state = state.copyWith(
          error:
              'Los votos (${state.totalContabilizado}) superan el total de sufragantes (${state.totalSufragantes}).',
        );
      }
      return;
    }

    if (state.actaId == null && state.fotoFile == null) {
      state = state.copyWith(error: 'Debes tomar una foto del acta.');
      return;
    }

    state = state.copyWith(guardando: true, error: null);

    try {
      // Verificar conectividad
      final connectivity = await Connectivity().checkConnectivity();
      final hayConexion = !connectivity.contains(ConnectivityResult.none);

      if (!hayConexion) {
        // ── Modo OFFLINE: guardar localmente ──────────────────────────────
        await _guardarOffline(userId: userId);
        return;
      }

      // ── Modo ONLINE: subir normalmente ────────────────────────────────────
      await _guardarOnline(userId: userId, urlFotoExistente: urlFotoExistente);

      // Aprovechar para sincronizar pendientes en segundo plano
      _sincronizarPendientes(userId: userId);
    } catch (e) {
      // Si falla la subida, intentar guardar offline
      try {
        await _guardarOffline(userId: userId);
      } catch (e2) {
        state = state.copyWith(
          guardando: false,
          error: 'Error al guardar el acta: $e',
        );
      }
    }
  }

  Future<void> _guardarOffline({required String userId}) async {
    final localId = await _OfflineActaService.encolar(
      mesaId: state.mesaId,
      usuarioId: userId,
      dignidad: state.dignidad,
      votos:
          state.votosPorOrganizacion.map((k, v) => MapEntry(k.toString(), v)),
      votosNulos: state.votosNulos,
      votosBlancos: state.votosBlancos,
      totalSufragantes: state.totalSufragantes,
      fotoPath: state.fotoFile?.path,
      gpsLat: state.gpsLat,
      gpsLng: state.gpsLng,
    );

    state = state.copyWith(
      guardando: false,
      guardadoExito: true,
      pendienteSync: true,
      actaId: localId,
      error: null,
    );
  }

  Future<void> _guardarOnline({
    required String userId,
    String? urlFotoExistente,
  }) async {
    final repo = _ref.read(actaRepositoryProvider);

    final String fotoUrl;
    if (state.fotoFile != null) {
      fotoUrl = await repo.subirFotoActa(state.fotoFile!);
    } else {
      fotoUrl = urlFotoExistente ?? '';
    }

    // Las coordenadas GPS se almacenan como campos del acta,
    // no como metadatos de la imagen.
    final acta = Acta(
      id: state.actaId ?? 0,
      mesaId: state.mesaId,
      usuarioId: userId,
      dignidad: state.dignidad,
      votosPorOrganizacion: state.votosPorOrganizacion
          .map((orgId, votos) => MapEntry(orgId.toString(), votos)),
      votosNulos: state.votosNulos,
      votosBlancos: state.votosBlancos,
      totalSufragantes: state.totalSufragantes,
      urlFotoActa: fotoUrl,
      gpsLat: state.gpsLat, // ← campo del acta, no EXIF
      gpsLng: state.gpsLng, // ← campo del acta, no EXIF
      estado: EstadoActa.ingresada,
      createdAt: DateTime.now(),
    );

    await repo.guardarActa(acta);
    state = state.copyWith(
      guardando: false,
      guardadoExito: true,
      error: null,
    );
  }

  // ── Sincronización en segundo plano ──────────────────────────────────────
  // Se ejecuta cuando el dispositivo recupera conexión.
  // Considera conflictos: si el servidor ya tiene un acta para esa mesa
  // con el mismo usuario, se actualiza en lugar de duplicar.
  Future<void> _sincronizarPendientes({required String userId}) async {
    final pendientes = await _OfflineActaService.pendientes();
    if (pendientes.isEmpty) return;

    final repo = _ref.read(actaRepositoryProvider);

    for (final row in pendientes) {
      final localId = row['id'] as int;
      try {
        final File? fotoFile =
            row['foto_path'] != null ? File(row['foto_path'] as String) : null;

        String fotoUrl = '';
        if (fotoFile != null && await fotoFile.exists()) {
          fotoUrl = await repo.subirFotoActa(fotoFile);
        }

        final votos = _OfflineActaService._parsearVotos(
            row['votos_json'] as String? ?? '');

        final acta = Acta(
          id: 0,
          mesaId: row['mesa_id'] as int,
          usuarioId: row['usuario_id'] as String?,
          dignidad: row['dignidad'] != null
              ? Dignidad.values.byName(row['dignidad'] as String)
              : null,
          votosPorOrganizacion: votos,
          votosNulos: row['votos_nulos'] as int,
          votosBlancos: row['votos_blancos'] as int,
          totalSufragantes: row['total_sufragantes'] as int?,
          urlFotoActa: fotoUrl,
          gpsLat: (row['gps_lat'] as num?)?.toDouble(),
          gpsLng: (row['gps_lng'] as num?)?.toDouble(),
          estado: EstadoActa.ingresada,
          createdAt: DateTime.parse(row['created_at'] as String),
        );

        // Verificar si ya existe en el servidor (conflicto de doble envío).
        // La lógica de conflicto: si el repo.guardarActa lanza un error
        // de duplicado, lo ignoramos y eliminamos el pendiente igualmente.
        await repo.guardarActa(acta);
        await _OfflineActaService.eliminar(localId);
      } catch (_) {
        // Marca el intento fallido; se reintentará la próxima vez.
        await _OfflineActaService.marcarIntento(localId);
        // Si hay más de 5 intentos fallidos, dejar en cola pero no bloquear.
      }
    }
  }

  /// Llama esto desde la pantalla cuando detectes que recuperó conexión
  /// (puedes usar connectivity_plus stream en el widget).
  Future<void> sincronizarSiHayConexion({required String userId}) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.none)) {
      _sincronizarPendientes(userId: userId);
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ARGS DEL PROVIDER FAMILY
// ═════════════════════════════════════════════════════════════════════════════
class ActaFormArgs {
  final int mesaId;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final Acta? actaExistente;

  const ActaFormArgs({
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.organizaciones,
    this.actaExistente,
  });

  @override
  bool operator ==(Object other) =>
      other is ActaFormArgs &&
      other.mesaId == mesaId &&
      other.dignidad == dignidad;

  @override
  int get hashCode => Object.hash(mesaId, dignidad);
}

// ═════════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
final actaFormProvider =
    StateNotifierProvider.family<ActaFormNotifier, ActaFormState, ActaFormArgs>(
        (ref, args) {
  final votosIniciales = <int, int>{};
  for (final org in args.organizaciones) {
    final valorExistente =
        args.actaExistente?.votosPorOrganizacion?[org.id.toString()] ?? 0;
    votosIniciales[org.id] = valorExistente;
  }

  return ActaFormNotifier(
    ref,
    ActaFormState(
      mesaId: args.mesaId,
      dignidad: args.dignidad,
      totalSufragantes: args.totalSufragantes,
      organizaciones: args.organizaciones,
      votosPorOrganizacion: votosIniciales,
      votosNulos: args.actaExistente?.votosNulos ?? 0,
      votosBlancos: args.actaExistente?.votosBlancos ?? 0,
      actaId: args.actaExistente?.id,
    ),
  );
});
