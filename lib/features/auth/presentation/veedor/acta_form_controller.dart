// lib/features/auth/presentation/veedor/acta_form_controller.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/repositories/acta_repository_provider.dart';

// ─────────────────────────────────────────
// Estado del formulario
// ─────────────────────────────────────────
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
  final bool guardando;
  final String? error;
  final bool guardadoExito;
  final int? actaId; // null = nueva, int = edición

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
    this.guardando = false,
    this.error,
    this.guardadoExito = false,
    this.actaId,
  });

  int get totalContabilizado =>
      votosPorOrganizacion.values.fold(0, (a, b) => a + b) +
      votosNulos +
      votosBlancos;

  bool get esConsistente => totalContabilizado <= totalSufragantes;

  // En edición permitimos guardar aunque no haya nueva foto (conservamos la URL existente)
  bool get puedeGuardar =>
      gpsLat != null && gpsLng != null && esConsistente && !guardando;

  ActaFormState copyWith({
    Map<int, int>? votosPorOrganizacion,
    int? votosNulos,
    int? votosBlancos,
    File? fotoFile,
    double? gpsLat,
    double? gpsLng,
    bool? cargandoGps,
    bool? guardando,
    String? error,
    bool? guardadoExito,
    int? actaId,
  }) {
    return ActaFormState(
      mesaId: mesaId,
      dignidad: dignidad,
      totalSufragantes: totalSufragantes,
      organizaciones: organizaciones,
      votosPorOrganizacion: votosPorOrganizacion ?? this.votosPorOrganizacion,
      votosNulos: votosNulos ?? this.votosNulos,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      fotoFile: fotoFile ?? this.fotoFile,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      cargandoGps: cargandoGps ?? this.cargandoGps,
      guardando: guardando ?? this.guardando,
      error: error,
      guardadoExito: guardadoExito ?? this.guardadoExito,
      actaId: actaId ?? this.actaId,
    );
  }
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class ActaFormNotifier extends StateNotifier<ActaFormState> {
  final Ref _ref;

  ActaFormNotifier(this._ref, ActaFormState initialState) : super(initialState) {
    _obtenerGpsAutomatico();
  }

  void actualizarVotosOrganizacion(int orgId, int votos) {
    final mapa = Map<int, int>.from(state.votosPorOrganizacion);
    mapa[orgId] = votos < 0 ? 0 : votos;
    state = state.copyWith(votosPorOrganizacion: mapa, error: null);
  }

  void actualizarVotosNulos(int valor) =>
      state = state.copyWith(votosNulos: valor < 0 ? 0 : valor, error: null);

  void actualizarVotosBlancos(int valor) =>
      state = state.copyWith(votosBlancos: valor < 0 ? 0 : valor, error: null);

  Future<void> _obtenerGpsAutomatico() => obtenerGps();

  Future<void> obtenerGps() async {
    state = state.copyWith(cargandoGps: true, error: null);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        state = state.copyWith(
          cargandoGps: false,
          error: 'El servicio GPS está desactivado en el dispositivo.',
        );
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        state = state.copyWith(
          cargandoGps: false,
          error: 'Permiso de ubicación denegado. Actívalo en Configuración.',
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      state = state.copyWith(
        gpsLat: pos.latitude,
        gpsLng: pos.longitude,
        cargandoGps: false,
      );
    } catch (e) {
      state = state.copyWith(
        cargandoGps: false,
        error: 'Error al obtener GPS: $e',
      );
    }
  }

  Future<void> procesarFotoDesdeCamera(XFile xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        state = state.copyWith(error: 'No se pudo procesar la imagen.');
        return;
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
        return;
      }

      state = state.copyWith(fotoFile: file, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Error al procesar la foto: $e');
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

  Future<void> guardarActa({
    required String userId,
    String? urlFotoExistente, // URL de la foto ya registrada (modo edición)
  }) async {
    if (!state.puedeGuardar) {
      if (state.gpsLat == null) {
        state = state.copyWith(error: 'Debes obtener la ubicación GPS.');
      } else if (!state.esConsistente) {
        state = state.copyWith(
          error:
              'Los votos (${state.totalContabilizado}) superan el total de sufragantes (${state.totalSufragantes}).',
        );
      }
      return;
    }

    // Para acta NUEVA, la foto es obligatoria
    if (state.actaId == null && state.fotoFile == null) {
      state = state.copyWith(error: 'Debes tomar una foto del acta.');
      return;
    }

    state = state.copyWith(guardando: true, error: null);

    try {
      final repo = _ref.read(actaRepositoryProvider);

      // Subir nueva foto solo si se tomó una en esta sesión
      final String fotoUrl;
      if (state.fotoFile != null) {
        fotoUrl = await repo.subirFotoActa(state.fotoFile!);
      } else {
        fotoUrl = urlFotoExistente ?? '';
      }

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
        gpsLat: state.gpsLat,
        gpsLng: state.gpsLng,
        estado: EstadoActa.ingresada,
        createdAt: DateTime.now(),
      );

      await repo.guardarActa(acta);

      state = state.copyWith(guardando: false, guardadoExito: true);
    } catch (e) {
      state = state.copyWith(
        guardando: false,
        error: 'Error al guardar el acta: $e',
      );
    }
  }
}

// ─────────────────────────────────────────
// Args del provider family
// ─────────────────────────────────────────
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

// ─────────────────────────────────────────
// Provider
// ─────────────────────────────────────────
final actaFormProvider = StateNotifierProvider.family<ActaFormNotifier,
    ActaFormState, ActaFormArgs>((ref, args) {
  // Precargar votos si hay acta existente
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