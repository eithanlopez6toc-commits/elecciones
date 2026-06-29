// lib/features/auth/presentation/veedor/acta_form_screen.dart
//
// CAMBIOS vs versión anterior:
//  1. Foto SIEMPRE horizontal (corrección EXIF con paquete image)
//  2. Foto completa (BoxFit.contain) + toque para agrandar (InteractiveViewer)
//  3. Guardar → Diálogo éxito → [Aceptar] → vuelve al formulario (SIN vista previa)
//  4. GPS: mapa OSM con marcador (flutter_map) + coordenadas en texto
//  5. GPS desactivado → diálogo "Activar GPS"; sin permiso → diálogo "Otorgar permisos"
//  6. Votos deben ser EXACTOS al total de sufragantes (ver acta_form_controller.dart)
//  7. Persistencia offline con sqflite + sync automático al reconectar
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/acta.dart';
import '../../domain/entities/organizacion_politica.dart';
import 'acta_form_controller.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═════════════════════════════════════════════════════════════════════════════
class _T {
  static const primary = Color(0xFF003EC7);
  static const outline = Color(0xFFE2E8F0);
  static const cardRadius = 12.0;
  static const background = Color(0xFFF7F8FA);
  static const surfaceContainerLow = Color(0xFFEFF6FF);
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceVariant = Color(0xFF475569);
  static const greyLight = Color(0xFF94A3B8);
  static const success = Color(0xFF10B981);
  static const successContainer = Color(0xFFECFDF5);
  static const errorColor = Color(0xFFEF4444);
  static const errorContainer = Color(0xFFFEF2F2);
  static const warningColor = Color(0xFFF59E0B);
  static const warningContainer = Color(0xFFFFFBEB);
  static const brandAccent = Color(0xFFEFF6FF);
}

// ═════════════════════════════════════════════════════════════════════════════
// DATOS DE PARTIDOS POR DIGNIDAD
// ═════════════════════════════════════════════════════════════════════════════
const _partidosPorDignidad = {
  Dignidad.prefecto: [
    '1. UNES',
    '5. Movimiento Revolución Ciudadana',
    '6. Partido Social Cristiano',
    '12. Avanza',
    '18. Pachakutik',
  ],
  Dignidad.alcalde: [
    '1. UNES',
    '5. Movimiento Revolución Ciudadana',
    '6. Partido Social Cristiano',
    '12. Avanza',
    '18. Pachakutik',
  ],
};

// ═════════════════════════════════════════════════════════════════════════════
// HELPER: corregir rotación EXIF y forzar landscape
// ═════════════════════════════════════════════════════════════════════════════
Future<File> _corregirRotacionFoto(XFile xfile) async {
  final bytes = await xfile.readAsBytes();
  final original = img.decodeImage(bytes);
  if (original == null) return File(xfile.path);

  img.Image corregida = img.bakeOrientation(original);

  if (corregida.height > corregida.width) {
    corregida = img.copyRotate(corregida, angle: 90);
  }

  final file = File(xfile.path);
  await file.writeAsBytes(img.encodeJpg(corregida, quality: 90));
  return file;
}

// ═════════════════════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═════════════════════════════════════════════════════════════════════════════
class ActaFormScreen extends ConsumerStatefulWidget {
  final int mesaId;
  final String mesaNombre;
  final String recintoNombre;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final String userId;
  final Acta? actaExistente;
  final bool soloLectura;

  const ActaFormScreen({
    super.key,
    required this.mesaId,
    required this.mesaNombre,
    required this.recintoNombre,
    required this.dignidad,
    required this.totalSufragantes,
    required this.organizaciones,
    required this.userId,
    this.actaExistente,
    this.soloLectura = false,
  });

  @override
  ConsumerState<ActaFormScreen> createState() => _ActaFormScreenState();
}

class _ActaFormScreenState extends ConsumerState<ActaFormScreen> {
  late final Map<int, TextEditingController> _ctrlOrg;
  late final TextEditingController _ctrlNulos;
  late final TextEditingController _ctrlBlancos;
  late final ActaFormArgs _args;

  bool _modoCorreccion = false;

  bool get _esEdicion => widget.actaExistente != null;
  bool get _esCoordinador => widget.soloLectura;
  bool get _editable => !_esCoordinador || _modoCorreccion;

  @override
  void initState() {
    super.initState();
    _args = ActaFormArgs(
      mesaId: widget.mesaId,
      dignidad: widget.dignidad,
      totalSufragantes: widget.totalSufragantes,
      organizaciones: widget.organizaciones,
      actaExistente: widget.actaExistente,
    );

    final votosExistentes = widget.actaExistente?.votosPorOrganizacion ?? {};
    _ctrlOrg = {
      for (final o in widget.organizaciones)
        o.id: TextEditingController(
          text: (votosExistentes[o.id.toString()] ?? 0).toString(),
        ),
    };
    _ctrlNulos = TextEditingController(
        text: (widget.actaExistente?.votosNulos ?? 0).toString());
    _ctrlBlancos = TextEditingController(
        text: (widget.actaExistente?.votosBlancos ?? 0).toString());

    // Modal informativo al abrir (solo creación, solo veedor)
    if (!_esEdicion && !_esCoordinador) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarModalPartidos();
      });
    }

    // Escuchar reconexión para sincronizar pendientes
    Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && mounted) {
        ref
            .read(actaFormProvider(_args).notifier)
            .sincronizarSiHayConexion(userId: widget.userId);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrlOrg.values) c.dispose();
    _ctrlNulos.dispose();
    _ctrlBlancos.dispose();
    super.dispose();
  }

  // ── Modal de partidos al abrir ────────────────────────────────────────────
  void _mostrarModalPartidos() {
    final partidos = _partidosPorDignidad[widget.dignidad] ?? [];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          const Icon(Icons.how_to_vote_outlined, color: _T.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Organizaciones — ${widget.dignidad.etiqueta}',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _T.primary),
            ),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta mesa tiene ${partidos.length} organizaciones políticas para ${widget.dignidad.etiqueta}:',
              style: const TextStyle(fontSize: 13, color: _T.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ...partidos.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: _T.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(p,
                        style: const TextStyle(
                            fontSize: 13,
                            color: _T.onSurface,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _T.warningContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: const [
                Icon(Icons.info_outline, size: 14, color: _T.warningColor),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'El total de votos debe coincidir exactamente con el total de sufragantes de la mesa.',
                    style: TextStyle(fontSize: 11, color: _T.warningColor),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _T.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ── Cámara: verificar GPS y permisos antes de abrir ──────────────────────
  Future<void> _abrirCamara() async {
    var locationStatus = await Permission.locationWhenInUse.status;

    if (locationStatus.isDenied) {
      locationStatus = await Permission.locationWhenInUse.request();
    }

    if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(children: [
            Icon(Icons.gps_off, color: _T.errorColor, size: 22),
            SizedBox(width: 8),
            Text('Permiso GPS requerido',
                style: TextStyle(
                    fontSize: 15,
                    color: _T.errorColor,
                    fontWeight: FontWeight.w700)),
          ]),
          content: const Text(
            'Se necesita acceso a la ubicación GPS para validar y registrar el acta correctamente.\n\n'
            'Sin el permiso GPS no es posible fotografiar el acta.',
            style: TextStyle(fontSize: 13, color: _T.onSurface),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _T.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (locationStatus.isPermanentlyDenied) {
                  await openAppSettings();
                } else {
                  await Permission.locationWhenInUse.request();
                }
              },
              child: const Text('Otorgar permisos'),
            ),
          ],
        ),
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(children: [
            Icon(Icons.location_off, color: _T.warningColor, size: 22),
            SizedBox(width: 8),
            Text('GPS desactivado',
                style: TextStyle(
                    fontSize: 15,
                    color: _T.warningColor,
                    fontWeight: FontWeight.w700)),
          ]),
          content: const Text(
            'El GPS de tu dispositivo está desactivado.\n\n'
            'Actívalo para poder fotografiar el acta con la ubicación de la mesa.',
            style: TextStyle(fontSize: 13, color: _T.onSurface),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _T.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Activar GPS'),
            ),
          ],
        ),
      );
      return;
    }

    final camStatus = await Permission.camera.request();
    if (!camStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Se necesita permiso de cámara para fotografiar el acta.'),
          backgroundColor: _T.warningColor,
        ));
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;

    final xfile = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
          builder: (_) => _CameraCapturePage(camera: cameras.first)),
    );

    if (xfile != null && mounted) {
      ref.read(actaFormProvider(_args).notifier).setProcesandoFoto(true);

      try {
        final fileCorregido = await _corregirRotacionFoto(xfile);

        await ref
            .read(actaFormProvider(_args).notifier)
            .procesarFotoDesdeCamera(XFile(fileCorregido.path));
      } catch (e) {
        ref.read(actaFormProvider(_args).notifier).setProcesandoFoto(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al procesar foto: $e'),
            backgroundColor: _T.errorColor,
          ));
        }
      }
    }
  }

  // ── Guardar con validación previa ─────────────────────────────────────────
  Future<void> _guardar() async {
    final state = ref.read(actaFormProvider(_args));

    // BLOQUEO: votos no coinciden exactamente con sufragantes
    if (!state.esConsistente) {
      final diferencia = state.totalSufragantes - state.totalContabilizado;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: _T.errorColor, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text('Votos inconsistentes',
                  style: TextStyle(
                      fontSize: 15,
                      color: _T.errorColor,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          content: Text(
            diferencia > 0
                ? 'Faltan $diferencia votos para llegar al total de sufragantes '
                    '(${state.totalSufragantes}). El total contabilizado debe ser exacto.'
                : 'El total de votos contabilizados (${state.totalContabilizado}) '
                    'supera el total de sufragantes de la mesa (${state.totalSufragantes}) '
                    'por ${-diferencia}.\n\nEl total debe coincidir exactamente.',
            style: const TextStyle(fontSize: 13, color: _T.onSurface),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _T.errorColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Corregir votos',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      return;
    }

    await ref
        .read(actaFormProvider(_args).notifier)
        .guardarActa(userId: widget.userId);

    final stateActualizado = ref.read(actaFormProvider(_args));
    if (stateActualizado.guardadoExito && mounted) {
      // Diálogo de ÉXITO — al aceptar, vuelve directo al formulario actualizado
      // (sin vista previa intermedia).
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: stateActualizado.pendienteSync
                    ? _T.warningContainer
                    : _T.successContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                stateActualizado.pendienteSync
                    ? Icons.cloud_off
                    : Icons.check_circle_outline,
                color: stateActualizado.pendienteSync
                    ? _T.warningColor
                    : _T.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              stateActualizado.pendienteSync
                  ? 'Acta guardada localmente'
                  : (_modoCorreccion
                      ? '¡Corrección guardada!'
                      : (_esEdicion
                          ? '¡Acta actualizada!'
                          : '¡Acta registrada!')),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: stateActualizado.pendienteSync
                    ? _T.warningColor
                    : _T.success,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              stateActualizado.pendienteSync
                  ? 'El acta se sincronizará automáticamente con el servidor cuando haya conexión a internet.'
                  : 'Los datos fueron enviados correctamente al servidor electoral.',
              style: const TextStyle(fontSize: 13, color: _T.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ]),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: stateActualizado.pendienteSync
                    ? _T.warningColor
                    : _T.primary,
                minimumSize: const Size(160, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              // Cierra el diálogo y se queda en ActaFormScreen,
              // ya con los datos actualizados y el botón "Actualizar acta" visible.
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(actaFormProvider(_args));

    ref.listen(actaFormProvider(_args), (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: _T.errorColor,
          duration: const Duration(seconds: 5),
        ));
      }
    });

    return Scaffold(
      backgroundColor: _T.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _T.primary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _T.outline, height: 1.0),
        ),
        leading: const BackButton(color: _T.primary),
        title: Row(children: [
          const Icon(Icons.shield_outlined, color: _T.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esCoordinador
                      ? 'Detalle del acta'
                      : (_esEdicion ? 'Editar acta' : 'Registrar acta'),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _T.primary),
                ),
                Text(
                  'Mesa ${widget.mesaNombre} — ${widget.dignidad.etiqueta}',
                  style:
                      const TextStyle(fontSize: 11, color: _T.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ]),
        actions: [
          if (_esEdicion && !_esCoordinador)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: _Pill(
                    label: 'Editando',
                    color: _T.warningColor,
                    bg: _T.warningContainer),
              ),
            ),
          if (_esCoordinador)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: _Pill(
                    label: 'Coordinador',
                    color: _T.warningColor,
                    bg: _T.warningContainer),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (state.pendienteSync) ...[
            _BannerOffline(
              onReintentarSync: () => ref
                  .read(actaFormProvider(_args).notifier)
                  .sincronizarSiHayConexion(userId: widget.userId),
            ),
            const SizedBox(height: 10),
          ],

          _CardInfoMesa(
            recinto: widget.recintoNombre,
            mesa: widget.mesaNombre,
            dignidad: widget.dignidad.etiqueta,
            totalSufragantes: widget.totalSufragantes,
          ),
          const SizedBox(height: 12),

          if (_esCoordinador && _esEdicion) ...[
            _CardEstadoActa(
              acta: widget.actaExistente!,
              modoCorreccion: _modoCorreccion,
              onActivarCorreccion: () => setState(() => _modoCorreccion = true),
            ),
            const SizedBox(height: 12),
          ],

          _CardVotos(
            organizaciones: widget.organizaciones,
            ctrlOrg: _ctrlOrg,
            ctrlNulos: _ctrlNulos,
            ctrlBlancos: _ctrlBlancos,
            state: state,
            editable: _editable,
            onOrgChanged: (id, val) => ref
                .read(actaFormProvider(_args).notifier)
                .actualizarVotosOrganizacion(id, val),
            onNulosChanged: (val) => ref
                .read(actaFormProvider(_args).notifier)
                .actualizarVotosNulos(val),
            onBlancosChanged: (val) => ref
                .read(actaFormProvider(_args).notifier)
                .actualizarVotosBlancos(val),
          ),
          const SizedBox(height: 12),

          _CardFoto(
            fotoFile: state.fotoFile,
            urlFotoExistente: widget.actaExistente?.urlFotoActa,
            procesandoFoto: state.procesandoFoto,
            editable: _editable,
            onTomarFoto: _abrirCamara,
          ),
          const SizedBox(height: 12),

          _CardGps(
            lat: state.gpsLat,
            lng: state.gpsLng,
            cargando: state.cargandoGps,
          ),
          const SizedBox(height: 16),

          if (_editable) ...[
            if (!state.esConsistente) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _T.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _T.errorColor.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.block, size: 16, color: _T.errorColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No puedes guardar: el total debe ser exactamente '
                      '${state.totalSufragantes} votos (actualmente ${state.totalContabilizado}).',
                      style:
                          const TextStyle(fontSize: 12, color: _T.errorColor),
                    ),
                  ),
                ]),
              ),
            ],

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                    !state.esConsistente ? _T.greyLight : _T.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: state.guardando ? null : _guardar,
              icon: state.guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(_esEdicion || _esCoordinador
                      ? Icons.update_outlined
                      : Icons.save_outlined),
              label: Text(
                state.guardando
                    ? 'Guardando...'
                    : (_modoCorreccion
                        ? 'Guardar corrección'
                        : (_esEdicion ? 'Actualizar acta' : 'Registrar acta')),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _modoCorreccion
                  ? 'Como coordinador estás corrigiendo los datos del acta.'
                  : (_esEdicion
                      ? 'Puedes corregir los datos o la foto en cualquier momento.'
                      : 'El acta quedará en estado "ingresada" hasta ser validada.'),
              style: const TextStyle(fontSize: 11, color: _T.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BANNER OFFLINE
// ═════════════════════════════════════════════════════════════════════════════
class _BannerOffline extends StatelessWidget {
  final VoidCallback onReintentarSync;
  const _BannerOffline({required this.onReintentarSync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _T.warningContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.warningColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.cloud_off, size: 16, color: _T.warningColor),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Guardado localmente. Se enviará al servidor cuando haya conexión.',
            style: TextStyle(fontSize: 12, color: _T.warningColor),
          ),
        ),
        GestureDetector(
          onTap: onReintentarSync,
          child: const Icon(Icons.sync, size: 16, color: _T.warningColor),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: ESTADO ACTUAL (coordinador) + botón corrección
// ═════════════════════════════════════════════════════════════════════════════
class _CardEstadoActa extends StatelessWidget {
  final Acta acta;
  final bool modoCorreccion;
  final VoidCallback onActivarCorreccion;

  const _CardEstadoActa({
    required this.acta,
    required this.modoCorreccion,
    required this.onActivarCorreccion,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Estado del acta',
      icono: Icons.verified_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Estado actual:',
                style: TextStyle(fontSize: 13, color: _T.onSurfaceVariant)),
            const SizedBox(width: 10),
            _pillEstado(acta.estado),
          ]),
          const SizedBox(height: 10),
          if (!modoCorreccion)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.warningColor,
                side: const BorderSide(color: _T.warningColor),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onActivarCorreccion,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Corregir datos del acta',
                  style: TextStyle(fontSize: 13)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _T.warningContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.edit_outlined, size: 14, color: _T.warningColor),
                SizedBox(width: 6),
                Text('Modo corrección activado',
                    style: TextStyle(
                        fontSize: 12,
                        color: _T.warningColor,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _pillEstado(EstadoActa estado) {
    return switch (estado) {
      EstadoActa.ingresada => _pill('Ingresada', _T.primary, _T.brandAccent),
      EstadoActa.revisada =>
        _pill('Escrutado 100%', _T.success, _T.successContainer),
      EstadoActa.conNovedad =>
        _pill('Con novedad', _T.errorColor, _T.errorContainer),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: INFO DE LA MESA
// ═════════════════════════════════════════════════════════════════════════════
class _CardInfoMesa extends StatelessWidget {
  final String recinto, mesa, dignidad;
  final int totalSufragantes;
  const _CardInfoMesa({
    required this.recinto,
    required this.mesa,
    required this.dignidad,
    required this.totalSufragantes,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Información de la mesa',
      icono: Icons.place_outlined,
      child: Column(children: [
        Row(children: [
          Expanded(
              child: _Campo(label: 'Recinto', valor: recinto, disabled: true)),
          const SizedBox(width: 10),
          Expanded(
              child: _Campo(label: 'Mesa / JRV', valor: mesa, disabled: true)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child:
                  _Campo(label: 'Dignidad', valor: dignidad, disabled: true)),
          const SizedBox(width: 10),
          Expanded(
              child: _Campo(
                  label: 'Total sufragantes',
                  valor: totalSufragantes.toString(),
                  disabled: true)),
        ]),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: VOTOS
// ═════════════════════════════════════════════════════════════════════════════
class _CardVotos extends StatelessWidget {
  final List<OrganizacionPolitica> organizaciones;
  final Map<int, TextEditingController> ctrlOrg;
  final TextEditingController ctrlNulos, ctrlBlancos;
  final ActaFormState state;
  final bool editable;
  final void Function(int, int) onOrgChanged;
  final void Function(int) onNulosChanged, onBlancosChanged;

  const _CardVotos({
    required this.organizaciones,
    required this.ctrlOrg,
    required this.ctrlNulos,
    required this.ctrlBlancos,
    required this.state,
    required this.editable,
    required this.onOrgChanged,
    required this.onNulosChanged,
    required this.onBlancosChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inconsistente = !state.esConsistente;

    return _Seccion(
      titulo: 'Votos por organización política',
      icono: Icons.how_to_vote_outlined,
      child: Column(children: [
        if (inconsistente)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _T.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.errorColor.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 16, color: _T.errorColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El total debe ser exactamente ${state.totalSufragantes} votos '
                  '(actualmente ${state.totalContabilizado}).',
                  style: const TextStyle(fontSize: 12, color: _T.errorColor),
                ),
              ),
            ]),
          ),

        ...organizaciones.map((org) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FilaVotos(
                label: '${org.listaNumero}. ${org.nombre}',
                controller: ctrlOrg[org.id]!,
                color: _T.surfaceContainerLow,
                textColor: _T.primary,
                enabled: editable,
                onChanged: (v) => onOrgChanged(org.id, int.tryParse(v) ?? 0),
              ),
            )),

        Container(
            height: 1,
            color: _T.outline,
            margin: const EdgeInsets.symmetric(vertical: 8)),

        _FilaVotos(
          label: 'Votos nulos',
          controller: ctrlNulos,
          color: _T.warningContainer,
          textColor: _T.warningColor,
          enabled: editable,
          onChanged: (v) => onNulosChanged(int.tryParse(v) ?? 0),
        ),
        const SizedBox(height: 8),
        _FilaVotos(
          label: 'Votos blancos',
          controller: ctrlBlancos,
          color: _T.surfaceContainerLow,
          textColor: _T.primary,
          enabled: editable,
          onChanged: (v) => onBlancosChanged(int.tryParse(v) ?? 0),
        ),

        Container(
            height: 1,
            color: _T.outline,
            margin: const EdgeInsets.symmetric(vertical: 8)),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total contabilizado',
              style: TextStyle(fontSize: 12, color: _T.onSurfaceVariant)),
          Text(
            '${state.totalContabilizado} / ${state.totalSufragantes}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: state.esConsistente ? _T.success : _T.errorColor,
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Consistencia',
              style: TextStyle(fontSize: 12, color: _T.onSurfaceVariant)),
          _BadgeConsistencia(esConsistente: state.esConsistente),
        ]),
      ]),
    );
  }
}

class _FilaVotos extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color, textColor;
  final bool enabled;
  final ValueChanged<String> onChanged;
  const _FilaVotos({
    required this.label,
    required this.controller,
    required this.color,
    required this.textColor,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _T.outline)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _T.outline)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _T.outline)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _T.primary, width: 1.5)),
            filled: true,
            fillColor: enabled ? Colors.white : _T.surfaceContainerLow,
          ),
        ),
      ),
    ]);
  }
}

class _BadgeConsistencia extends StatelessWidget {
  final bool esConsistente;
  const _BadgeConsistencia({required this.esConsistente});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: esConsistente ? _T.successContainer : _T.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        esConsistente ? '✓ Consistente' : '✗ Inconsistente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: esConsistente ? _T.success : _T.errorColor,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: FOTO
// ═════════════════════════════════════════════════════════════════════════════
class _CardFoto extends StatelessWidget {
  final File? fotoFile;
  final String? urlFotoExistente;
  final bool procesandoFoto;
  final bool editable;
  final VoidCallback onTomarFoto;

  const _CardFoto({
    required this.fotoFile,
    required this.urlFotoExistente,
    required this.procesandoFoto,
    required this.editable,
    required this.onTomarFoto,
  });

  void _verFotoCompleta(BuildContext context, Widget imagen) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: imagen,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneNuevaFoto = fotoFile != null;
    final tieneFotoExistente =
        urlFotoExistente != null && urlFotoExistente!.isNotEmpty;

    return _Seccion(
      titulo: 'Fotografía del acta física',
      icono: Icons.camera_alt_outlined,
      child: Column(children: [
        if (procesandoFoto)
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: _T.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _T.primary),
                  SizedBox(height: 10),
                  Text('Procesando foto y capturando GPS...',
                      style:
                          TextStyle(fontSize: 12, color: _T.onSurfaceVariant)),
                ],
              ),
            ),
          )
        else if (tieneNuevaFoto) ...[
          GestureDetector(
            onTap: () => _verFotoCompleta(
              context,
              Image.file(fotoFile!, fit: BoxFit.contain),
            ),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  fotoFile!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 220,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('Toca para ampliar',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ),
            ]),
          ),
          if (editable) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.onSurfaceVariant,
                side: const BorderSide(color: _T.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTomarFoto,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retomar foto'),
            ),
          ],
        ] else if (tieneFotoExistente) ...[
          GestureDetector(
            onTap: () => _verFotoCompleta(
              context,
              Image.network(urlFotoExistente!, fit: BoxFit.contain),
            ),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  urlFotoExistente!,
                  height: 220,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 220,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: _T.primary))),
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: _T.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: _T.greyLight)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Foto actual',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('Toca para ampliar',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ),
            ]),
          ),
          if (editable) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.warningColor,
                side: const BorderSide(color: _T.warningColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTomarFoto,
              icon: const Icon(Icons.camera_alt_outlined, size: 16),
              label: const Text('Reemplazar foto'),
            ),
          ],
        ] else if (editable)
          GestureDetector(
            onTap: onTomarFoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                border: Border.all(color: _T.outline, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: _T.surfaceContainerLow,
              ),
              child: const Column(children: [
                Icon(Icons.add_a_photo_outlined, size: 36, color: _T.primary),
                SizedBox(height: 8),
                Text('Tomar foto del acta',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _T.primary)),
                SizedBox(height: 4),
                Text(
                    'La ubicación GPS se captura automáticamente al fotografiar',
                    style: TextStyle(fontSize: 11, color: _T.greyLight),
                    textAlign: TextAlign.center),
              ]),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text('Sin fotografía',
                style: TextStyle(fontSize: 12, color: _T.greyLight)),
          ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: GPS — coordenadas + mapa OSM con marcador
// ═════════════════════════════════════════════════════════════════════════════
class _CardGps extends StatelessWidget {
  final double? lat, lng;
  final bool cargando;
  const _CardGps(
      {required this.lat, required this.lng, required this.cargando});

  @override
  Widget build(BuildContext context) {
    final tieneGps = lat != null && lng != null;

    return _Seccion(
      titulo: 'Ubicación GPS',
      icono: Icons.gps_fixed,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cargando
                ? _T.surfaceContainerLow
                : tieneGps
                    ? _T.successContainer
                    : _T.warningContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            if (cargando)
              const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _T.primary))
            else
              Icon(
                tieneGps
                    ? Icons.verified_user_outlined
                    : Icons.location_off_outlined,
                size: 16,
                color: tieneGps ? _T.success : _T.warningColor,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                cargando
                    ? 'Capturando coordenadas...'
                    : tieneGps
                        ? 'Ubicación capturada correctamente'
                        : 'Las coordenadas se capturan al tomar la foto',
                style: TextStyle(
                  fontSize: 12,
                  color: cargando
                      ? _T.onSurfaceVariant
                      : tieneGps
                          ? _T.success
                          : _T.warningColor,
                ),
              ),
            ),
          ]),
        ),

        Row(children: [
          Expanded(
              child: _Campo(
                  label: 'Latitud',
                  valor: lat != null ? lat!.toStringAsFixed(6) : '—',
                  disabled: true)),
          const SizedBox(width: 10),
          Expanded(
              child: _Campo(
                  label: 'Longitud',
                  valor: lng != null ? lng!.toStringAsFixed(6) : '—',
                  disabled: true)),
        ]),

        if (tieneGps) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat!, lng!),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.tuapp.veedor',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(lat!, lng!),
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),
        const Row(children: [
          Icon(Icons.info_outline, size: 12, color: _T.greyLight),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              'Las coordenadas se capturan automáticamente al fotografiar el acta y se almacenan como campo del registro.',
              style: TextStyle(fontSize: 11, color: _T.greyLight),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═════════════════════════════════════════════════════════════════════════════
class _Pill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Pill({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;
  const _Seccion(
      {required this.titulo, required this.icono, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_T.cardRadius),
        border: Border.all(color: _T.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: _T.surfaceContainerLow,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_T.cardRadius),
              topRight: Radius.circular(_T.cardRadius),
            ),
          ),
          child: Row(children: [
            Icon(icono, size: 16, color: _T.primary),
            const SizedBox(width: 8),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _T.primary)),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: child),
      ]),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label, valor;
  final bool disabled;
  const _Campo(
      {required this.label, required this.valor, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _T.onSurfaceVariant)),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: disabled ? _T.surfaceContainerLow : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _T.outline),
        ),
        child: Text(valor,
            style: TextStyle(
                fontSize: 13,
                color: disabled ? _T.onSurfaceVariant : _T.onSurface)),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PÁGINA DE CÁMARA
// ═════════════════════════════════════════════════════════════════════════════
class _CameraCapturePage extends StatefulWidget {
  final CameraDescription camera;
  const _CameraCapturePage({required this.camera});

  @override
  State<_CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<_CameraCapturePage> {
  late CameraController _controller;
  late Future<void> _initFuture;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capturar() async {
    if (_capturando) return;
    setState(() => _capturando = true);
    try {
      final xfile = await _controller.takePicture();
      if (mounted) Navigator.of(context).pop(xfile);
    } catch (e) {
      setState(() => _capturando = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al capturar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Fotografía del acta'),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined,
                        size: 48, color: Colors.white54),
                    const SizedBox(height: 12),
                    Text(
                      'Error al iniciar la cámara:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ]),
            );
          }
          return Stack(children: [
            Center(child: CameraPreview(_controller)),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.gps_fixed, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('GPS se captura al fotografiar',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _capturar,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: _capturando
                          ? Colors.grey
                          : Colors.white.withOpacity(0.85),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 36, color: Colors.black),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}