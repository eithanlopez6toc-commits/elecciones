// lib/features/auth/presentation/veedor/acta_form_screen.dart
// CAMBIO RESPECTO A LA VERSION ANTERIOR:
//  - Acepta `actaExistente` opcional para modo edición
//  - Precarga los valores del acta existente en los controllers
//  - El botón guarda O actualiza según corresponda
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../domain/entities/organizacion_politica.dart';
import 'acta_form_controller.dart';
import '../../domain/entities/acta.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN SYSTEM — Democracy Core
// ═════════════════════════════════════════════════════════════════════════════
class _Tema {
  static const primary = Color(0xFF003EC7);
  static const outline = Color(0xFFE2E8F0);
  static const cardRadius = 8.0;
  static const background = Color(0xFFFAF8FF);
  static const surfaceContainerLow = Color(0xFFF2F3FF);
  static const onSurface = Color(0xFF131B2E);
  static const onSurfaceVariant = Color(0xFF434656);
  static const greyLight = Color(0xFFC3C5D9);
  static const success = Color(0xFF006C49);
  static const successContainer = Color(0xFFE8F5E9);
  static const errorColor = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const warningColor = Color(0xFF9C6B00);
  static const warningContainer = Color(0xFFFFF3E0);
}

class ActaFormScreen extends ConsumerStatefulWidget {
  final int mesaId;
  final String mesaNombre;
  final String recintoNombre;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final String userId;
  final Acta? actaExistente; // null = nueva, not null = edición

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
  });

  @override
  ConsumerState<ActaFormScreen> createState() => _ActaFormScreenState();
}

class _ActaFormScreenState extends ConsumerState<ActaFormScreen> {
  late final Map<int, TextEditingController> _ctrlOrg;
  late final TextEditingController _ctrlNulos;
  late final TextEditingController _ctrlBlancos;
  late final ActaFormArgs _args;

  bool get _esEdicion => widget.actaExistente != null;

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

    // Precargar valores si es edición
    final votosExistentes = widget.actaExistente?.votosPorOrganizacion ?? {};

    _ctrlOrg = {
      for (final o in widget.organizaciones)
        o.id: TextEditingController(
          text: (votosExistentes[o.id.toString()] ?? 0).toString(),
        ),
    };
    _ctrlNulos = TextEditingController(
      text: (widget.actaExistente?.votosNulos ?? 0).toString(),
    );
    _ctrlBlancos = TextEditingController(
      text: (widget.actaExistente?.votosBlancos ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    for (final c in _ctrlOrg.values) c.dispose();
    _ctrlNulos.dispose();
    _ctrlBlancos.dispose();
    super.dispose();
  }

  Future<void> _abrirCamara() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;

    final xfile = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        builder: (_) => _CameraCapturePage(camera: cameras.first),
      ),
    );

    if (xfile != null) {
      await ref
          .read(actaFormProvider(_args).notifier)
          .procesarFotoDesdeCamera(xfile);
    }
  }

  Future<void> _guardar() async {
    final notifier = ref.read(actaFormProvider(_args).notifier);
    await notifier.guardarActa(userId: widget.userId);

    final state = ref.read(actaFormProvider(_args));
    if (state.guardadoExito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Acta actualizada correctamente'
                : 'Acta registrada correctamente',
          ),
          backgroundColor: _Tema.success,
        ),
      );
      Navigator.of(context)
          .pop(true); // retorna true para que el panel refresque
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(actaFormProvider(_args));

    ref.listen(actaFormProvider(_args), (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: _Tema.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: _Tema.background,
      appBar: AppBar(
        backgroundColor: _Tema.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _esEdicion ? 'Editar acta' : 'Registrar acta',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Mesa ${widget.mesaNombre} — ${widget.dignidad.etiqueta}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_esEdicion)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _Tema.warningColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Editando',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _CardInfoMesa(
              recinto: widget.recintoNombre,
              mesa: widget.mesaNombre,
              dignidad: widget.dignidad.etiqueta,
              totalSufragantes: widget.totalSufragantes,
            ),
            const SizedBox(height: 10),
            _CardVotos(
              organizaciones: widget.organizaciones,
              ctrlOrg: _ctrlOrg,
              ctrlNulos: _ctrlNulos,
              ctrlBlancos: _ctrlBlancos,
              state: state,
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
            const SizedBox(height: 10),
            _CardFoto(
              fotoFile: state.fotoFile,
              urlFotoExistente: widget.actaExistente?.urlFotoActa,
              onTomarFoto: _abrirCamara,
            ),
            const SizedBox(height: 10),
            _CardGps(
              lat: state.gpsLat,
              lng: state.gpsLng,
              cargando: state.cargandoGps,
              onObtener: () =>
                  ref.read(actaFormProvider(_args).notifier).obtenerGps(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _Tema.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: state.guardando ? null : _guardar,
                icon: state.guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_esEdicion
                        ? Icons.update_outlined
                        : Icons.save_outlined),
                label: Text(
                  state.guardando
                      ? 'Guardando...'
                      : (_esEdicion ? 'Actualizar acta' : 'Registrar acta'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _esEdicion
                  ? 'Puedes corregir los datos o la foto en cualquier momento.'
                  : 'El acta quedará en estado "ingresada" hasta ser validada por el coordinador.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: Info de la mesa (sin cambios)
// ─────────────────────────────────────────
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      _Campo(label: 'Recinto', valor: recinto, disabled: true)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _Campo(label: 'Mesa / JRV', valor: mesa, disabled: true)),
            ],
          ),
          const SizedBox(height: 8),
          _Campo(label: 'Dignidad', valor: dignidad, disabled: true),
          const SizedBox(height: 8),
          _Campo(
            label: 'Total sufragantes habilitados',
            valor: totalSufragantes.toString(),
            disabled: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: Votos (sin cambios)
// ─────────────────────────────────────────
class _CardVotos extends StatelessWidget {
  final List<OrganizacionPolitica> organizaciones;
  final Map<int, TextEditingController> ctrlOrg;
  final TextEditingController ctrlNulos, ctrlBlancos;
  final ActaFormState state;
  final void Function(int, int) onOrgChanged;
  final void Function(int) onNulosChanged, onBlancosChanged;

  const _CardVotos({
    required this.organizaciones,
    required this.ctrlOrg,
    required this.ctrlNulos,
    required this.ctrlBlancos,
    required this.state,
    required this.onOrgChanged,
    required this.onNulosChanged,
    required this.onBlancosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Votos por organización política',
      icono: Icons.how_to_vote_outlined,
      child: Column(
        children: [
          ...organizaciones.map((org) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FilaVotos(
                  label: '${org.listaNumero}. ${org.nombre}',
                  controller: ctrlOrg[org.id]!,
                  color: _Tema.surfaceContainerLow,
                  textColor: _Tema.primary,
                  onChanged: (v) => onOrgChanged(org.id, int.tryParse(v) ?? 0),
                ),
              )),
          const Divider(height: 16),
          _FilaVotos(
            label: 'Votos nulos',
            controller: ctrlNulos,
            color: _Tema.warningContainer,
            textColor: _Tema.warningColor,
            onChanged: (v) => onNulosChanged(int.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 8),
          _FilaVotos(
            label: 'Votos blancos',
            controller: ctrlBlancos,
            color: _Tema.surfaceContainerLow,
            textColor: _Tema.primary,
            onChanged: (v) => onBlancosChanged(int.tryParse(v) ?? 0),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total contabilizado',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(
                '${state.totalContabilizado} / ${state.totalSufragantes}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: state.esConsistente
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consistencia',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              _BadgeConsistencia(esConsistente: state.esConsistente),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaVotos extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color, textColor;
  final ValueChanged<String> onChanged;

  const _FilaVotos({
    required this.label,
    required this.controller,
    required this.color,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeConsistencia extends StatelessWidget {
  final bool esConsistente;
  const _BadgeConsistencia({required this.esConsistente});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: esConsistente ? _Tema.successContainer : _Tema.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        esConsistente ? '✓ Consistente' : '✗ Inconsistente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: esConsistente ? _Tema.success : _Tema.errorColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: Foto — NUEVO: muestra foto existente si hay URL
// ─────────────────────────────────────────
class _CardFoto extends StatelessWidget {
  final dynamic fotoFile;
  final String? urlFotoExistente;
  final VoidCallback onTomarFoto;

  const _CardFoto({
    required this.fotoFile,
    required this.urlFotoExistente,
    required this.onTomarFoto,
  });

  @override
  Widget build(BuildContext context) {
    final tieneNuevaFoto = fotoFile != null;
    final tieneFotoExistente =
        urlFotoExistente != null && urlFotoExistente!.isNotEmpty;

    return _Seccion(
      titulo: 'Fotografía del acta física',
      icono: Icons.camera_alt_outlined,
      child: Column(
        children: [
          // Muestra la nueva foto tomada en sesión
          if (tieneNuevaFoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                fotoFile,
                height: 200,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onTomarFoto,
              icon: const Icon(Icons.refresh),
              label: const Text('Retomar foto'),
            ),
          ]
          // Muestra la foto ya registrada en Supabase
          else if (tieneFotoExistente) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    urlFotoExistente!,
                    height: 200,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 80,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.grey),
                      ),
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
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Foto actual',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onTomarFoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Reemplazar foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade300),
              ),
            ),
          ]
          // Sin foto
          else ...[
            GestureDetector(
              onTap: onTomarFoto,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _Tema.outline,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: _Tema.surfaceContainerLow,
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 36, color: _Tema.primary),
                    SizedBox(height: 8),
                    Text(
                      'Tomar foto del acta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _Tema.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Se usará la cámara trasera del dispositivo',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: GPS (sin cambios)
// ─────────────────────────────────────────
class _CardGps extends StatelessWidget {
  final double? lat, lng;
  final bool cargando;
  final VoidCallback onObtener;

  const _CardGps({
    required this.lat,
    required this.lng,
    required this.cargando,
    required this.onObtener,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Ubicación GPS',
      icono: Icons.gps_fixed,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Campo(
                  label: 'Latitud',
                  valor: lat != null ? lat!.toStringAsFixed(6) : '—',
                  disabled: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Campo(
                  label: 'Longitud',
                  valor: lng != null ? lng!.toStringAsFixed(6) : '—',
                  disabled: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _Tema.outline),
                foregroundColor: _Tema.primary,
              ),
              onPressed: cargando ? null : onObtener,
              icon: cargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                cargando ? 'Obteniendo GPS...' : 'Actualizar ubicación',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Se captura automáticamente al abrir el formulario',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widgets auxiliares compartidos
// ─────────────────────────────────────────
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: _Tema.surfaceContainerLow,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, size: 16, color: _Tema.primary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _Tema.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label, valor;
  final bool disabled;

  const _Campo({
    required this.label,
    required this.valor,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              color: disabled ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Página de cámara (sin cambios)
// ─────────────────────────────────────────
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
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Center(child: CameraPreview(_controller)),
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
            ],
          );
        },
      ),
    );
  }
}
