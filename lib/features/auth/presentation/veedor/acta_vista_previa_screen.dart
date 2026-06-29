// lib/features/auth/presentation/veedor/acta_vista_previa_screen.dart
//
// Pantalla de VISTA PREVIA del acta tras guardar/registrar.
// - Veedor: ve todos los datos + botón "Actualizar acta"
// - Coordinador: ve datos + botón "Actualizar acta" + botón "Validar acta"
// - Mapa GPS interactivo con caché offline (NetworkTileProvider + cachedNetworkImage)
// - Foto: soporta tanto URL remota como path local (modo offline)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/acta.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/repositories/acta_repository_provider.dart';
import 'acta_form_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: ¿es un path local o una URL remota?
// ─────────────────────────────────────────────────────────────────────────────
bool _esPathLocal(String? valor) => valor != null && !valor.startsWith('http');

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA
// ─────────────────────────────────────────────────────────────────────────────
class ActaVistaPreviewScreen extends ConsumerStatefulWidget {
  final Acta acta;
  final String mesaNombre;
  final String recintoNombre;
  final List<OrganizacionPolitica> organizaciones;
  final String userId;
  final bool esCoordinador;
  final bool pendienteSync;

  const ActaVistaPreviewScreen({
    super.key,
    required this.acta,
    required this.mesaNombre,
    required this.recintoNombre,
    required this.organizaciones,
    required this.userId,
    this.esCoordinador = false,
    this.pendienteSync = false,
  });

  @override
  ConsumerState<ActaVistaPreviewScreen> createState() =>
      _ActaVistaPreviewScreenState();
}

class _ActaVistaPreviewScreenState
    extends ConsumerState<ActaVistaPreviewScreen> {
  bool _validando = false;

  Future<void> _validarActa() async {
    setState(() => _validando = true);
    try {
      final repo = ref.read(actaRepositoryProvider);
      await repo.guardarActa(widget.acta.copyWith(estado: EstadoActa.revisada));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Acta validada correctamente'),
          backgroundColor: _T.success,
        ));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al validar: $e'),
          backgroundColor: _T.errorColor,
        ));
      }
    } finally {
      if (mounted) setState(() => _validando = false);
    }
  }

  Future<void> _irAEditar() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActaFormScreen(
          mesaId: widget.acta.mesaId,
          mesaNombre: widget.mesaNombre,
          recintoNombre: widget.recintoNombre,
          dignidad: widget.acta.dignidad!,
          totalSufragantes: widget.acta.totalSufragantes ?? 0,
          organizaciones: widget.organizaciones,
          userId: widget.userId,
          actaExistente: widget.acta,
          soloLectura: widget.esCoordinador,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _verFotoCompleta(Widget imagen) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(children: [
          Center(
              child: InteractiveViewer(
                  minScale: 0.5, maxScale: 5.0, child: imagen)),
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

  // ── Widget de foto: detecta si es path local o URL ──────────────────────
  Widget _buildFoto(String fotoRuta) {
    if (_esPathLocal(fotoRuta)) {
      // Foto offline: la mostramos desde el archivo local
      final file = File(fotoRuta);
      return GestureDetector(
        onTap: () => _verFotoCompleta(Image.file(file, fit: BoxFit.contain)),
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              height: 220,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _fotoError(),
            ),
          ),
          _botonAmpliar(),
        ]),
      );
    }
    // Foto online: URL remota
    return GestureDetector(
      onTap: () =>
          _verFotoCompleta(Image.network(fotoRuta, fit: BoxFit.contain)),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            fotoRuta,
            height: 220,
            width: double.infinity,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const SizedBox(
                    height: 220,
                    child: Center(
                        child: CircularProgressIndicator(color: _T.primary))),
            errorBuilder: (_, __, ___) => _fotoError(),
          ),
        ),
        _botonAmpliar(),
      ]),
    );
  }

  Widget _fotoError() => Container(
        height: 80,
        decoration: BoxDecoration(
            color: _T.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8)),
        child: const Center(
            child: Icon(Icons.broken_image_outlined, color: _T.greyLight)),
      );

  Widget _botonAmpliar() => Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(4)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.zoom_in, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text('Toca para ampliar',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ]),
        ),
      );

  // ── Mapa con caché offline ───────────────────────────────────────────────
  Widget _buildMapa(double lat, double lng) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // ★ FIX mapa offline: CachedTileProvider cachea los tiles descargados.
            // Cuando no hay conexión, sirve desde caché en lugar de pantalla blanca.
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tuapp.veedor',
              tileProvider: CachedTileProvider(store: MemCacheStore()),
              // Fallback cuando el tile no está en caché y no hay conexión:
              // muestra un tile gris en vez de error rojo
              errorTileCallback: (tile, error, stackTrace) {},
            ),
            MarkerLayer(markers: [
              Marker(
                point: LatLng(lat, lng),
                width: 44,
                height: 44,
                child:
                    const Icon(Icons.location_pin, color: Colors.red, size: 44),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acta = widget.acta;
    final tieneGps = acta.gpsLat != null && acta.gpsLng != null;
    final tieneFoto = acta.urlFotoActa != null && acta.urlFotoActa!.isNotEmpty;

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
          const Icon(Icons.preview_outlined, color: _T.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Vista previa del acta',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _T.primary)),
              Text(
                'Mesa ${widget.mesaNombre} — ${acta.dignidad?.etiqueta ?? ''}',
                style:
                    const TextStyle(fontSize: 11, color: _T.onSurfaceVariant),
              ),
            ]),
          ),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _pillEstado(acta.estado)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Banner offline
          if (widget.pendienteSync) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _T.warningContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _T.warningColor.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.cloud_off, size: 16, color: _T.warningColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Guardado localmente. Se enviará al servidor cuando haya conexión.',
                    style: TextStyle(fontSize: 12, color: _T.warningColor),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],

          // Info mesa
          _Seccion(
            titulo: 'Información de la mesa',
            icono: Icons.place_outlined,
            child: Column(children: [
              Row(children: [
                Expanded(
                    child:
                        _Campo(label: 'Recinto', valor: widget.recintoNombre)),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _Campo(label: 'Mesa / JRV', valor: widget.mesaNombre)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _Campo(
                        label: 'Dignidad',
                        valor: acta.dignidad?.etiqueta ?? '—')),
                const SizedBox(width: 10),
                Expanded(
                    child: _Campo(
                        label: 'Total sufragantes',
                        valor: acta.totalSufragantes?.toString() ?? '—')),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // Votos
          _Seccion(
            titulo: 'Votos registrados',
            icono: Icons.how_to_vote_outlined,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...widget.organizaciones.map((org) {
                final votos =
                    acta.votosPorOrganizacion?[org.id.toString()] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FilaResumen(
                    partido: '${org.listaNumero}. ${org.nombre}',
                    candidato: org.candidatoNombre,
                    valor: votos.toString(),
                    colorFondo: _T.surfaceContainerLow,
                    colorTexto: _T.primary,
                  ),
                );
              }),
              Container(
                  height: 1,
                  color: _T.outline,
                  margin: const EdgeInsets.symmetric(vertical: 6)),
              _FilaResumen(
                partido: 'Votos nulos',
                valor: acta.votosNulos.toString(),
                colorFondo: _T.warningContainer,
                colorTexto: _T.warningColor,
              ),
              const SizedBox(height: 6),
              _FilaResumen(
                partido: 'Votos blancos',
                valor: acta.votosBlancos.toString(),
                colorFondo: _T.surfaceContainerLow,
                colorTexto: _T.primary,
              ),
              Container(
                  height: 1,
                  color: _T.outline,
                  margin: const EdgeInsets.symmetric(vertical: 6)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total contabilizado',
                    style: TextStyle(
                        fontSize: 12,
                        color: _T.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                Text(
                  _totalContabilizado().toString(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _T.onSurface),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // Foto
          _Seccion(
            titulo: 'Fotografía del acta física',
            icono: Icons.camera_alt_outlined,
            child: tieneFoto
                ? _buildFoto(acta.urlFotoActa!)
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('Sin fotografía',
                        style: TextStyle(fontSize: 12, color: _T.greyLight)),
                  ),
          ),
          const SizedBox(height: 12),

          // GPS
          _Seccion(
            titulo: 'Ubicación GPS',
            icono: Icons.gps_fixed,
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: _Campo(
                        label: 'Latitud',
                        valor: acta.gpsLat != null
                            ? acta.gpsLat!.toStringAsFixed(6)
                            : '—')),
                const SizedBox(width: 10),
                Expanded(
                    child: _Campo(
                        label: 'Longitud',
                        valor: acta.gpsLng != null
                            ? acta.gpsLng!.toStringAsFixed(6)
                            : '—')),
              ]),
              if (tieneGps) ...[
                const SizedBox(height: 12),
                // ★ FIX mapa offline: usa _buildMapa con CachedTileProvider
                _buildMapa(acta.gpsLat!, acta.gpsLng!),
              ] else
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _T.warningContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(children: [
                    Icon(Icons.location_off_outlined,
                        size: 14, color: _T.warningColor),
                    SizedBox(width: 6),
                    Text('Sin coordenadas GPS registradas',
                        style: TextStyle(fontSize: 12, color: _T.warningColor)),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 12),

          // Estado
          _Seccion(
            titulo: 'Estado del acta',
            icono: Icons.verified_outlined,
            child: Row(children: [
              const Text('Estado actual:',
                  style: TextStyle(fontSize: 13, color: _T.onSurfaceVariant)),
              const SizedBox(width: 10),
              _pillEstado(acta.estado),
            ]),
          ),
          const SizedBox(height: 20),

          // Botón Actualizar (veedor y coordinador)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.primary,
              side: const BorderSide(color: _T.primary),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _irAEditar,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              widget.esCoordinador
                  ? 'Corregir datos del acta'
                  : 'Actualizar acta',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          // Botón Validar (solo coordinador, solo si no está revisada)
          if (widget.esCoordinador && acta.estado != EstadoActa.revisada) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _T.success,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _validando ? null : _validarActa,
              icon: _validando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                _validando ? 'Validando...' : 'Validar acta',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  int _totalContabilizado() {
    final sumaOrg = widget.acta.votosPorOrganizacion?.values
            .fold<int>(0, (a, b) => a + b) ??
        0;
    return sumaOrg + widget.acta.votosNulos + widget.acta.votosBlancos;
  }

  Widget _pillEstado(EstadoActa estado) => switch (estado) {
        EstadoActa.ingresada => _pill('Ingresada', _T.primary, _T.brandAccent),
        EstadoActa.revisada =>
          _pill('Escrutado 100%', _T.success, _T.successContainer),
        EstadoActa.conNovedad =>
          _pill('Con novedad', _T.errorColor, _T.errorContainer),
      };

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS REUTILIZABLES
// ─────────────────────────────────────────────────────────────────────────────
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
  const _Campo({required this.label, required this.valor});

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
          color: _T.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _T.outline),
        ),
        child: Text(valor,
            style: const TextStyle(fontSize: 13, color: _T.onSurfaceVariant)),
      ),
    ]);
  }
}

class _FilaResumen extends StatelessWidget {
  final String partido, valor;
  final String? candidato;
  final Color colorFondo, colorTexto;

  const _FilaResumen({
    required this.partido,
    required this.valor,
    this.candidato,
    required this.colorFondo,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        flex: 3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              color: colorFondo, borderRadius: BorderRadius.circular(8)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(partido,
                    style: TextStyle(
                        fontSize: 12,
                        color: colorTexto,
                        fontWeight: FontWeight.w600)),
                if (candidato != null && candidato!.isNotEmpty)
                  Text(candidato!,
                      style: TextStyle(
                          fontSize: 11, color: colorTexto.withOpacity(0.75))),
              ]),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _T.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _T.outline),
          ),
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _T.onSurface),
          ),
        ),
      ),
    ]);
  }
}
