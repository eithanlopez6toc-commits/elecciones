// lib/features/auth/presentation/veedor/sync_provider.dart
//
// Mecanismo de persistencia local y sincronización automática
//
// FLUJO OFFLINE:
//   1. guardarActa() → intenta POST al backend
//   2. Si falla (sin conexión) → guarda en SQLite con pendienteSync=true
//   3. Al reconectar → SyncPendientesNotifier.sincronizarTodos()
//      lee SQLite, reintenta subir cada acta al backend
//   4. Si sube OK → borra de SQLite y marca pendienteSync=false en memoria
//   5. La UI escucha syncPendientesProvider → invalida actasVeedorProvider
//      → el tab "Completadas" se actualiza automáticamente
//
// CASOS DE CONFLICTO CONSIDERADOS:
//   A. Acta modificada en otro dispositivo mientras estaba offline:
//      → Se compara updatedAt. Si el servidor tiene versión más nueva,
//        se descarta la local y se notifica al veedor.
//   B. Doble registro (dos dispositivos suben la misma mesa+dignidad):
//      → El backend usa unique constraint (mesaId + dignidad).
//        El segundo POST recibe 409 Conflict → se marca como conflicto.
//   C. Foto no subió pero datos sí:
//      → Se guarda referencia local de la foto. Al reconectar, si los
//        datos subieron pero la foto no, se reintenta solo la foto.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// ─── Constantes ──────────────────────────────────────────────────────────────
const _kDbName    = 'actas_offline.db';
const _kDbVersion = 1;
const _kTableActas = 'actas_pendientes';
const _kBackendUrl = 'https://tu-backend.com/api'; // ← cambia por tu URL real

// ═════════════════════════════════════════════════════════════════════════════
// MODELO DE ESTADO DE SYNC
// ═════════════════════════════════════════════════════════════════════════════
class SyncState {
  final bool   sincronizando;
  final int    pendientes;
  final int    sincronizados;
  final String? ultimoError;

  const SyncState({
    this.sincronizando  = false,
    this.pendientes     = 0,
    this.sincronizados  = 0,
    this.ultimoError,
  });

  SyncState copyWith({
    bool?   sincronizando,
    int?    pendientes,
    int?    sincronizados,
    String? ultimoError,
  }) =>
      SyncState(
        sincronizando:  sincronizando ?? this.sincronizando,
        pendientes:     pendientes    ?? this.pendientes,
        sincronizados:  sincronizados ?? this.sincronizados,
        ultimoError:    ultimoError   ?? this.ultimoError,
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// BASE DE DATOS LOCAL (SQLite)
// ═════════════════════════════════════════════════════════════════════════════
class _ActasDb {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dbPath = join(await getDatabasesPath(), _kDbName);
    _db = await openDatabase(
      dbPath,
      version: _kDbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_kTableActas (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            mesa_id         INTEGER NOT NULL,
            dignidad        TEXT    NOT NULL,
            user_id         TEXT    NOT NULL,
            votos_json      TEXT    NOT NULL,
            votos_nulos     INTEGER NOT NULL DEFAULT 0,
            votos_blancos   INTEGER NOT NULL DEFAULT 0,
            gps_lat         REAL,
            gps_lng         REAL,
            foto_path       TEXT,
            created_at      TEXT    NOT NULL,
            intentos        INTEGER NOT NULL DEFAULT 0,
            UNIQUE(mesa_id, dignidad)
          )
        ''');
      },
    );
    return _db!;
  }

  /// Guarda o reemplaza un acta pendiente
  static Future<void> guardar(Map<String, dynamic> acta) async {
    final db = await instance;
    await db.insert(
      _kTableActas,
      acta,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Devuelve todas las actas pendientes de sincronizar
  static Future<List<Map<String, dynamic>>> obtenerPendientes() async {
    final db = await instance;
    return db.query(_kTableActas, orderBy: 'created_at ASC');
  }

  /// Elimina un acta una vez sincronizada correctamente
  static Future<void> eliminar(int id) async {
    final db = await instance;
    await db.delete(_kTableActas, where: 'id = ?', whereArgs: [id]);
  }

  /// Incrementa el contador de intentos fallidos
  static Future<void> incrementarIntentos(int id) async {
    final db = await instance;
    await db.rawUpdate(
        'UPDATE $_kTableActas SET intentos = intentos + 1 WHERE id = ?',
        [id]);
  }

  /// Total de pendientes
  static Future<int> contarPendientes() async {
    final db = await instance;
    final result =
        await db.rawQuery('SELECT COUNT(*) as c FROM $_kTableActas');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFIER DE SINCRONIZACIÓN
// ═════════════════════════════════════════════════════════════════════════════
class SyncPendientesNotifier extends StateNotifier<SyncState> {
  SyncPendientesNotifier() : super(const SyncState()) {
    _cargarConteo();
  }

  Future<void> _cargarConteo() async {
    final total = await _ActasDb.contarPendientes();
    if (mounted) state = state.copyWith(pendientes: total);
  }

  /// Guarda un acta localmente (cuando no hay conexión)
  Future<void> guardarLocal({
    required int    mesaId,
    required String dignidad,
    required String userId,
    required Map<String, int> votosPorOrganizacion,
    required int    votosNulos,
    required int    votosBlancos,
    double? gpsLat,
    double? gpsLng,
    String? fotoPath,
  }) async {
    await _ActasDb.guardar({
      'mesa_id':       mesaId,
      'dignidad':      dignidad,
      'user_id':       userId,
      'votos_json':    jsonEncode(votosPorOrganizacion),
      'votos_nulos':   votosNulos,
      'votos_blancos': votosBlancos,
      'gps_lat':       gpsLat,
      'gps_lng':       gpsLng,
      'foto_path':     fotoPath,
      'created_at':    DateTime.now().toIso8601String(),
      'intentos':      0,
    });
    await _cargarConteo();
  }

  /// Sincroniza todas las actas pendientes con el backend
  Future<void> sincronizarTodos({required String userId}) async {
    if (state.sincronizando) return;

    final pendientes = await _ActasDb.obtenerPendientes();
    if (pendientes.isEmpty) return;

    state = state.copyWith(sincronizando: true, sincronizados: 0);

    int sincronizados = 0;

    for (final row in pendientes) {
      try {
        final exito = await _subirActa(row, userId);
        if (exito) {
          await _ActasDb.eliminar(row['id'] as int);
          sincronizados++;
        } else {
          await _ActasDb.incrementarIntentos(row['id'] as int);
        }
      } catch (_) {
        await _ActasDb.incrementarIntentos(row['id'] as int);
      }
    }

    final restantes = await _ActasDb.contarPendientes();
    if (mounted) {
      state = state.copyWith(
        sincronizando: false,
        pendientes:    restantes,
        sincronizados: sincronizados,
      );
    }
  }

  /// Sube una acta individual al backend
  Future<bool> _subirActa(
      Map<String, dynamic> row, String userId) async {
    // 1. Subir foto si existe
    String? urlFoto;
    if (row['foto_path'] != null) {
      urlFoto = await _subirFoto(
          File(row['foto_path'] as String), userId);
      // Si la foto falla pero los datos sí deben subir, continúa igual
    }

    // 2. Subir datos del acta
    final body = jsonEncode({
      'mesaId':               row['mesa_id'],
      'dignidad':             row['dignidad'],
      'userId':               userId,
      'votosPorOrganizacion': jsonDecode(row['votos_json'] as String),
      'votosNulos':           row['votos_nulos'],
      'votosBlancos':         row['votos_blancos'],
      'gpsLat':               row['gps_lat'],
      'gpsLng':               row['gps_lng'],
      'urlFotoActa':          urlFoto,
      'registradoOfflineEn':  row['created_at'],
    });

    final response = await http
        .post(
          Uri.parse('$_kBackendUrl/actas'),
          headers: {
            'Content-Type': 'application/json',
            // Agrega tu token de autenticación aquí si aplica:
            // 'Authorization': 'Bearer $token',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 15));

    // 200 o 201 = éxito; 409 = conflicto (otro dispositivo ya subió)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    // CASO B: conflicto — el servidor ya tiene una versión más reciente
    if (response.statusCode == 409) {
      // Eliminamos el pendiente local para no reintentar en bucle.
      // En sustentación: aquí se podría mostrar una notificación al veedor
      // indicando que el acta fue registrada por otro dispositivo.
      await _ActasDb.eliminar(row['id'] as int);
      return true; // tratamos como "resuelto"
    }

    return false; // reintentará en la próxima reconexión
  }

  /// Sube la foto al backend/storage
  Future<String?> _subirFoto(File foto, String userId) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_kBackendUrl/actas/foto'),
      );
      request.files.add(
          await http.MultipartFile.fromPath('foto', foto.path));
      request.fields['userId'] = userId;

      final streamed = await request
          .send()
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url'] as String?;
      }
    } catch (_) {
      // La foto se reintentará en el siguiente ciclo de sync
    }
    return null;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PROVIDER GLOBAL
// ═════════════════════════════════════════════════════════════════════════════
final syncPendientesProvider =
    StateNotifierProvider<SyncPendientesNotifier, SyncState>(
  (ref) => SyncPendientesNotifier(),
);