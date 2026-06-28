// lib/features/auth/presentation/veedor/acta_form_screen.dart
//
// ROLES:
//  - soloLectura: false → veedor: puede crear nueva acta
//  - soloLectura: false + actaExistente != null → veedor: edita su acta
//  - soloLectura: true  → coordinador_recinto: ve datos y puede "Actualizar acta"
//    (corregir votos, foto, gps igual que el veedor, misma lógica guardarActa)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/organizacion_politica.dart';
import 'acta_form_controller.dart';
import '../../domain/entities/acta.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN SYSTEM — Portal Electoral Seguro (unificado con coordinador)
// ═════════════════════════════════════════════════════════════════════════════
class _Tema {
  static const primary             = Color(0xFF003EC7);
  static const outline             = Color(0xFFE2E8F0);
  static const cardRadius          = 12.0;
  static const background          = Color(0xFFF7F8FA);
  static const surfaceContainerLow = Color(0xFFEFF6FF);
  static const onSurface           = Color(0xFF0F172A);
  static const onSurfaceVariant    = Color(0xFF475569);
  static const greyLight           = Color(0xFF94A3B8);
  static const success             = Color(0xFF10B981);
  static const successContainer    = Color(0xFFECFDF5);
  static const errorColor          = Color(0xFFEF4444);
  static const errorContainer      = Color(0xFFFEF2F2);
  static const warningColor        = Color(0xFFF59E0B);
  static const warningContainer    = Color(0xFFFFFBEB);
  static const brandAccent         = Color(0xFFEFF6FF);
}

// ═════════════════════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═════════════════════════════════════════════════════════════════════════════
class ActaFormScreen extends ConsumerStatefulWidget {
  final int    mesaId;
  final String mesaNombre;
  final String recintoNombre;
  final Dignidad dignidad;
  final int    totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final String userId;
  final Acta?  actaExistente;

  /// false → veedor (crear o editar), true → coordinador_recinto (editar/corregir).
  /// En ambos casos se guarda con guardarActa(); la diferencia es visual y de badge.
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

  bool get _esEdicion     => widget.actaExistente != null;
  bool get _esCoordinador => widget.soloLectura;

  @override
  void initState() {
    super.initState();
    _args = ActaFormArgs(
      mesaId:           widget.mesaId,
      dignidad:         widget.dignidad,
      totalSufragantes: widget.totalSufragantes,
      organizaciones:   widget.organizaciones,
      actaExistente:    widget.actaExistente,
    );

    final votosExistentes = widget.actaExistente?.votosPorOrganizacion ?? {};
    _ctrlOrg = {
      for (final o in widget.organizaciones)
        o.id: TextEditingController(
          text: (votosExistentes[o.id.toString()] ?? 0).toString(),
        ),
    };
    _ctrlNulos   = TextEditingController(text: (widget.actaExistente?.votosNulos   ?? 0).toString());
    _ctrlBlancos = TextEditingController(text: (widget.actaExistente?.votosBlancos ?? 0).toString());
  }

  @override
  void dispose() {
    for (final c in _ctrlOrg.values) c.dispose();
    _ctrlNulos.dispose();
    _ctrlBlancos.dispose();
    super.dispose();
  }

  // ── Cámara con permiso explícito ──────────────────────────────────────────
  Future<void> _abrirCamara() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Se necesita permiso de cámara para fotografiar el acta.'),
          backgroundColor: _Tema.warningColor,
        ));
      }
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;
    final xfile = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(builder: (_) => _CameraCapturePage(camera: cameras.first)),
    );
    if (xfile != null) {
      await ref.read(actaFormProvider(_args).notifier).procesarFotoDesdeCamera(xfile);
    }
  }

  // ── GPS con permiso explícito ─────────────────────────────────────────────
  Future<void> _solicitarGps() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Se necesita permiso de ubicación para validar el recinto.'),
          backgroundColor: _Tema.warningColor,
        ));
      }
      return;
    }
    ref.read(actaFormProvider(_args).notifier).obtenerGps();
  }

  // ── Guardar — mismo método para veedor y coordinador ─────────────────────
  Future<void> _guardar() async {
    await ref.read(actaFormProvider(_args).notifier).guardarActa(userId: widget.userId);
    final state = ref.read(actaFormProvider(_args));
    if (state.guardadoExito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_esEdicion ? 'Acta actualizada correctamente' : 'Acta registrada correctamente'),
        backgroundColor: _Tema.success,
      ));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(actaFormProvider(_args));

    ref.listen(actaFormProvider(_args), (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: _Tema.errorColor,
          duration: const Duration(seconds: 4),
        ));
      }
    });

    return Scaffold(
      backgroundColor: _Tema.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _Tema.primary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _Tema.outline, height: 1.0),
        ),
        leading: const BackButton(color: _Tema.primary),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: _Tema.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _esCoordinador
                        ? 'Corrección de acta'
                        : (_esEdicion ? 'Editar acta' : 'Registrar acta'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: _Tema.primary),
                  ),
                  Text(
                    'Mesa ${widget.mesaNombre} — ${widget.dignidad.etiqueta}',
                    style: const TextStyle(fontSize: 11, color: _Tema.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_esCoordinador)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _Tema.warningContainer,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _Tema.warningColor.withOpacity(0.3)),
                  ),
                  child: const Text('Coordinador',
                      style: TextStyle(
                          fontSize: 10, color: _Tema.warningColor, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          else if (_esEdicion)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _Tema.warningContainer,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _Tema.warningColor.withOpacity(0.3)),
                  ),
                  child: const Text('Editando',
                      style: TextStyle(
                          fontSize: 10, color: _Tema.warningColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _CardInfoMesa(
              recinto:          widget.recintoNombre,
              mesa:             widget.mesaNombre,
              dignidad:         widget.dignidad.etiqueta,
              totalSufragantes: widget.totalSufragantes,
            ),
            const SizedBox(height: 12),

            // Si es coordinador y hay acta, muestra primero el panel de estado
            if (_esCoordinador && _esEdicion) ...[
              _CardEstadoActa(acta: widget.actaExistente!),
              const SizedBox(height: 12),
            ],

            _CardVotos(
              organizaciones:   widget.organizaciones,
              ctrlOrg:          _ctrlOrg,
              ctrlNulos:        _ctrlNulos,
              ctrlBlancos:      _ctrlBlancos,
              state:            state,
              onOrgChanged:     (id, val) => ref.read(actaFormProvider(_args).notifier).actualizarVotosOrganizacion(id, val),
              onNulosChanged:   (val)     => ref.read(actaFormProvider(_args).notifier).actualizarVotosNulos(val),
              onBlancosChanged: (val)     => ref.read(actaFormProvider(_args).notifier).actualizarVotosBlancos(val),
            ),
            const SizedBox(height: 12),
            _CardFoto(
              fotoFile:         state.fotoFile,
              urlFotoExistente: widget.actaExistente?.urlFotoActa,
              onTomarFoto:      _abrirCamara,
            ),
            const SizedBox(height: 12),
            _CardGps(
              lat:      state.gpsLat,
              lng:      state.gpsLng,
              cargando: state.cargandoGps,
              onObtener: _solicitarGps,
            ),
            const SizedBox(height: 16),

            // ── Botón principal ────────────────────────────────────────────
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _Tema.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: state.guardando ? null : _guardar,
              icon: state.guardando
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(_esEdicion || _esCoordinador
                      ? Icons.update_outlined
                      : Icons.save_outlined),
              label: Text(
                state.guardando
                    ? 'Guardando...'
                    : (_esCoordinador
                        ? 'Actualizar acta'
                        : (_esEdicion ? 'Actualizar acta' : 'Registrar acta')),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _esCoordinador
                  ? 'Como coordinador puedes corregir los datos del acta.'
                  : (_esEdicion
                      ? 'Puedes corregir los datos o la foto en cualquier momento.'
                      : 'El acta quedará en estado "ingresada" hasta ser validada.'),
              style: const TextStyle(fontSize: 11, color: _Tema.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: ESTADO ACTUAL (visible solo para coordinador, informativa)
// ═════════════════════════════════════════════════════════════════════════════
class _CardEstadoActa extends StatelessWidget {
  final Acta acta;
  const _CardEstadoActa({required this.acta});

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Estado del acta',
      icono:  Icons.verified_outlined,
      child: Row(
        children: [
          const Text('Estado actual:',
              style: TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
          const SizedBox(width: 10),
          _pillEstado(acta.estado),
          const Spacer(),
          const Icon(Icons.info_outline, size: 14, color: _Tema.greyLight),
          const SizedBox(width: 4),
          const Text('Puedes corregir y actualizar',
              style: TextStyle(fontSize: 11, color: _Tema.greyLight)),
        ],
      ),
    );
  }

  Widget _pillEstado(EstadoActa estado) {
    return switch (estado) {
      EstadoActa.ingresada  => _pill('Ingresada',       _Tema.primary,    _Tema.brandAccent),
      EstadoActa.revisada   => _pill('Escrutado 100%',  _Tema.success,    _Tema.successContainer),
      EstadoActa.conNovedad => _pill('Con novedad',     _Tema.errorColor, _Tema.errorContainer),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Text(label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: INFO DE LA MESA
// ═════════════════════════════════════════════════════════════════════════════
class _CardInfoMesa extends StatelessWidget {
  final String recinto, mesa, dignidad;
  final int totalSufragantes;
  const _CardInfoMesa({
    required this.recinto, required this.mesa,
    required this.dignidad, required this.totalSufragantes,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Información de la mesa',
      icono:  Icons.place_outlined,
      child: Column(children: [
        Row(children: [
          Expanded(child: _Campo(label: 'Recinto',    valor: recinto,   disabled: true)),
          const SizedBox(width: 10),
          Expanded(child: _Campo(label: 'Mesa / JRV', valor: mesa,      disabled: true)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Campo(label: 'Dignidad',          valor: dignidad,                  disabled: true)),
          const SizedBox(width: 10),
          Expanded(child: _Campo(label: 'Total sufragantes', valor: totalSufragantes.toString(), disabled: true)),
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
  final void Function(int, int) onOrgChanged;
  final void Function(int) onNulosChanged, onBlancosChanged;

  const _CardVotos({
    required this.organizaciones, required this.ctrlOrg,
    required this.ctrlNulos,      required this.ctrlBlancos,
    required this.state,          required this.onOrgChanged,
    required this.onNulosChanged, required this.onBlancosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Votos por organización política',
      icono:  Icons.how_to_vote_outlined,
      child: Column(children: [
        ...organizaciones.map((org) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _FilaVotos(
            label:      '${org.listaNumero}. ${org.nombre}',
            controller: ctrlOrg[org.id]!,
            color:      _Tema.surfaceContainerLow,
            textColor:  _Tema.primary,
            onChanged:  (v) => onOrgChanged(org.id, int.tryParse(v) ?? 0),
          ),
        )),
        Container(height: 1, color: _Tema.outline, margin: const EdgeInsets.symmetric(vertical: 8)),
        _FilaVotos(
          label:     'Votos nulos',
          controller: ctrlNulos,
          color:     _Tema.warningContainer,
          textColor: _Tema.warningColor,
          onChanged: (v) => onNulosChanged(int.tryParse(v) ?? 0),
        ),
        const SizedBox(height: 8),
        _FilaVotos(
          label:      'Votos blancos',
          controller: ctrlBlancos,
          color:      _Tema.surfaceContainerLow,
          textColor:  _Tema.primary,
          onChanged:  (v) => onBlancosChanged(int.tryParse(v) ?? 0),
        ),
        Container(height: 1, color: _Tema.outline, margin: const EdgeInsets.symmetric(vertical: 8)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total contabilizado',
              style: TextStyle(fontSize: 12, color: _Tema.onSurfaceVariant)),
          Text(
            '${state.totalContabilizado} / ${state.totalSufragantes}',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: state.esConsistente ? _Tema.success : _Tema.errorColor,
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Consistencia',
              style: TextStyle(fontSize: 12, color: _Tema.onSurfaceVariant)),
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
  final ValueChanged<String> onChanged;
  const _FilaVotos({
    required this.label,      required this.controller,
    required this.color,      required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: TextField(
          controller:   controller,
          keyboardType: TextInputType.number,
          textAlign:    TextAlign.right,
          onChanged:    onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _Tema.outline)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _Tema.outline)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _Tema.primary, width: 1.5)),
            filled:    true,
            fillColor: Colors.white,
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
        color: esConsistente ? _Tema.successContainer : _Tema.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        esConsistente ? '✓ Consistente' : '✗ Inconsistente',
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: esConsistente ? _Tema.success : _Tema.errorColor,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: FOTO
// ═════════════════════════════════════════════════════════════════════════════
class _CardFoto extends StatelessWidget {
  final dynamic fotoFile;
  final String? urlFotoExistente;
  final VoidCallback onTomarFoto;
  const _CardFoto({required this.fotoFile, required this.urlFotoExistente, required this.onTomarFoto});

  @override
  Widget build(BuildContext context) {
    final tieneNuevaFoto    = fotoFile != null;
    final tieneFotoExistente = urlFotoExistente != null && urlFotoExistente!.isNotEmpty;

    return _Seccion(
      titulo: 'Fotografía del acta física',
      icono:  Icons.camera_alt_outlined,
      child: Column(children: [
        if (tieneNuevaFoto) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(fotoFile, height: 200, fit: BoxFit.cover, width: double.infinity),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: _Tema.onSurfaceVariant,
                side: const BorderSide(color: _Tema.outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: onTomarFoto,
            icon:  const Icon(Icons.refresh, size: 16),
            label: const Text('Retomar foto'),
          ),
        ] else if (tieneFotoExistente) ...[
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                urlFotoExistente!,
                height: 200, fit: BoxFit.cover, width: double.infinity,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(height: 200,
                        child: Center(child: CircularProgressIndicator(color: _Tema.primary))),
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  decoration: BoxDecoration(
                      color: _Tema.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Icon(Icons.broken_image_outlined, color: _Tema.greyLight)),
                ),
              ),
            ),
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: const Text('Foto actual', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: _Tema.warningColor,
                side: const BorderSide(color: _Tema.warningColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: onTomarFoto,
            icon:  const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text('Reemplazar foto'),
          ),
        ] else ...[
          GestureDetector(
            onTap: onTomarFoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                border: Border.all(color: _Tema.outline, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: _Tema.surfaceContainerLow,
              ),
              child: const Column(children: [
                Icon(Icons.add_a_photo_outlined, size: 36, color: _Tema.primary),
                SizedBox(height: 8),
                Text('Tomar foto del acta',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _Tema.primary)),
                SizedBox(height: 4),
                Text('Se usará la cámara trasera del dispositivo',
                    style: TextStyle(fontSize: 11, color: _Tema.greyLight)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA: GPS
// ═════════════════════════════════════════════════════════════════════════════
class _CardGps extends StatelessWidget {
  final double? lat, lng;
  final bool cargando;
  final VoidCallback onObtener;
  const _CardGps({required this.lat, required this.lng, required this.cargando, required this.onObtener});

  @override
  Widget build(BuildContext context) {
    final tieneGps = lat != null && lng != null;
    return _Seccion(
      titulo: 'Ubicación GPS',
      icono:  Icons.gps_fixed,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: tieneGps ? _Tema.successContainer : _Tema.warningContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(
              tieneGps ? Icons.verified_user_outlined : Icons.location_off_outlined,
              size: 16,
              color: tieneGps ? _Tema.success : _Tema.warningColor,
            ),
            const SizedBox(width: 8),
            Text(
              tieneGps
                  ? 'Ubicación validada (${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)})'
                  : 'Coordenadas GPS no capturadas',
              style: TextStyle(
                  fontSize: 12, color: tieneGps ? _Tema.success : _Tema.warningColor),
            ),
          ]),
        ),
        Row(children: [
          Expanded(child: _Campo(label: 'Latitud',  valor: lat != null ? lat!.toStringAsFixed(6) : '—', disabled: true)),
          const SizedBox(width: 10),
          Expanded(child: _Campo(label: 'Longitud', valor: lng != null ? lng!.toStringAsFixed(6) : '—', disabled: true)),
        ]),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: _Tema.primary,
            minimumSize: const Size.fromHeight(44),
            side: const BorderSide(color: _Tema.outline),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: cargando ? null : onObtener,
          icon: cargando
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location, size: 16),
          label: Text(cargando ? 'Obteniendo GPS...' : 'Actualizar ubicación'),
        ),
        const SizedBox(height: 6),
        const Row(children: [
          Icon(Icons.info_outline, size: 12, color: _Tema.greyLight),
          SizedBox(width: 4),
          Text('Se captura automáticamente al abrir el formulario',
              style: TextStyle(fontSize: 11, color: _Tema.greyLight)),
        ]),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═════════════════════════════════════════════════════════════════════════════
class _Seccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;
  const _Seccion({required this.titulo, required this.icono, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_Tema.cardRadius),
        border: Border.all(color: _Tema.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: _Tema.surfaceContainerLow,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(_Tema.cardRadius),
              topRight: Radius.circular(_Tema.cardRadius),
            ),
          ),
          child: Row(children: [
            Icon(icono, size: 16, color: _Tema.primary),
            const SizedBox(width: 8),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _Tema.primary)),
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
  const _Campo({required this.label, required this.valor, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: _Tema.onSurfaceVariant)),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: disabled ? _Tema.surfaceContainerLow : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Tema.outline),
        ),
        child: Text(valor,
            style: TextStyle(
                fontSize: 13,
                color: disabled ? _Tema.onSurfaceVariant : _Tema.onSurface)),
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
  late Future<void>     _initFuture;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high, enableAudio: false);
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
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white54),
                const SizedBox(height: 12),
                Text('Error al iniciar la cámara:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            );
          }
          return Stack(children: [
            Center(child: CameraPreview(_controller)),
            Positioned(
              bottom: 32, left: 0, right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _capturar,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: _capturando ? Colors.grey : Colors.white.withOpacity(0.85),
                    ),
                    child: const Icon(Icons.camera_alt, size: 36, color: Colors.black),
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