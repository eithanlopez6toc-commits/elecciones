// lib/features/auth/presentation/veedor/veedor_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../controller/login_controller.dart';
import 'veedor_providers.dart';
import 'acta_form_screen.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN SYSTEM — Portal Electoral Seguro (unificado con coordinador)
// ═════════════════════════════════════════════════════════════════════════════
class _Tema {
  static const primary = Color(0xFF003EC7);
  static const outline = Color(0xFFE2E8F0);
  static const cardRadius = 12.0;
  static const background = Color(0xFFF7F8FA);
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
  static const surfaceContainerLow = Color(0xFFEFF6FF);
}

// ═════════════════════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═════════════════════════════════════════════════════════════════════════════
class VeedorPanelScreen extends ConsumerWidget {
  const VeedorPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider);
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mesasAsync = ref.watch(mesasVeedorProvider(usuario.id));

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
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: _Tema.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portal Electoral Seguro',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _Tema.primary),
                  ),
                  Text(
                    'Veedor: ${usuario.nombres} ${usuario.apellidos}',
                    style: const TextStyle(
                        fontSize: 11, color: _Tema.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                size: 20, color: _Tema.onSurfaceVariant),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: mesasAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _Tema.primary)),
        error: (e, _) => _ErrorView(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(mesasVeedorProvider(usuario.id)),
        ),
        data: (mesas) {
          if (mesas.isEmpty) return const _SinMesasView();
          return RefreshIndicator(
            color: _Tema.primary,
            onRefresh: () async =>
                ref.invalidate(mesasVeedorProvider(usuario.id)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ResumenBanner(mesas: mesas, usuarioId: usuario.id),
                const SizedBox(height: 16),
                const Text(
                  'Mesas asignadas',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _Tema.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                ...mesas.map((mesa) => _TarjetaMesa(mesa: mesa, usuario: usuario)),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Banner de resumen (KPI cards — mismo estilo que coordinador)
// ─────────────────────────────────────────
class _ResumenBanner extends ConsumerWidget {
  final List<MesaJrv> mesas;
  final String usuarioId;

  const _ResumenBanner({required this.mesas, required this.usuarioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasVeedorProvider(usuarioId));

    return actasAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
            child: CircularProgressIndicator(color: _Tema.primary, strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (actas) {
        final totalEsperadas = mesas.length * 2;
        final registradas = actas.length;
        final pendientes = totalEsperadas - registradas;
        final progreso = totalEsperadas == 0
            ? 0.0
            : (registradas / totalEsperadas).clamp(0.0, 1.0);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _CardKPI(
                    label: 'MESAS ASIGNADAS',
                    value: '${mesas.length}',
                    icon: Icons.how_to_vote_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CardKPI(
                    label: 'ACTAS REGISTRADAS',
                    value: '$registradas',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CardKPI(
                    label: 'PENDIENTES',
                    value: '$pendientes',
                    icon: Icons.pending_outlined,
                    destacar: pendientes > 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _CardKPI(
              label: 'PROGRESO DE ACTAS',
              value: '${(progreso * 100).toStringAsFixed(1)}%',
              icon: Icons.analytics_outlined,
              progress: progreso,
            ),
          ],
        );
      },
    );
  }
}

class _CardKPI extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double? progress;
  final bool destacar;

  const _CardKPI({
    required this.label,
    required this.value,
    required this.icon,
    this.progress,
    this.destacar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _Tema.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _Tema.greyLight,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: destacar ? _Tema.warningColor : _Tema.onSurface),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: _Tema.background,
                  color: _Tema.primary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Tarjeta por mesa
// ─────────────────────────────────────────
class _TarjetaMesa extends ConsumerWidget {
  final MesaJrv mesa;
  final Usuario usuario;

  const _TarjetaMesa({required this.mesa, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasPorMesaProvider(mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_Tema.cardRadius),
        border: Border.all(color: _Tema.outline),
      ),
      child: Column(
        children: [
          // Encabezado de la mesa — mismo estilo que tarjeta recinto
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: _Tema.surfaceContainerLow,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_Tema.cardRadius),
                topRight: Radius.circular(_Tema.cardRadius),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.how_to_vote_outlined,
                    size: 16, color: _Tema.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa ${mesa.numeroMesa} — ${mesa.genero}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _Tema.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filas de actas
          actasAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: $e',
                  style: const TextStyle(
                      color: _Tema.errorColor, fontSize: 12)),
            ),
            data: (actas) {
              final actaAlcalde = actas
                  .where((a) => a.dignidad == Dignidad.alcalde)
                  .firstOrNull;
              final actaPrefecto = actas
                  .where((a) => a.dignidad == Dignidad.prefecto)
                  .firstOrNull;

              return Column(
                children: [
                  _FilaActa(
                    dignidad: Dignidad.alcalde,
                    etiqueta: 'Acta de Alcalde',
                    icono: Icons.location_city_outlined,
                    acta: actaAlcalde,
                    onTap: () => _navegarAFormulario(
                        context, ref, Dignidad.alcalde, actaAlcalde),
                  ),
                  Container(height: 1, color: _Tema.outline),
                  _FilaActa(
                    dignidad: Dignidad.prefecto,
                    etiqueta: 'Acta de Prefecto',
                    icono: Icons.account_balance_outlined,
                    acta: actaPrefecto,
                    onTap: () => _navegarAFormulario(
                        context, ref, Dignidad.prefecto, actaPrefecto),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _navegarAFormulario(
    BuildContext context,
    WidgetRef ref,
    Dignidad dignidad,
    Acta? actaExistente,
  ) async {
    final orgsAsync =
        ref.read(organizacionesPorDignidadProvider(dignidad));
    final List<OrganizacionPolitica> orgs = orgsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActaFormScreen(
          mesaId: mesa.id,
          mesaNombre: mesa.numeroMesa.toString(),
          recintoNombre: 'Recinto ${mesa.recintoId}',
          dignidad: dignidad,
          totalSufragantes: 300, // TODO: cargar del recinto real
          organizaciones: orgs,
          userId: usuario.id,
          actaExistente: actaExistente,
          // El veedor puede crear Y editar
          soloLectura: false,
        ),
      ),
    );

    ref.invalidate(actasPorMesaProvider(mesa.id));
    ref.invalidate(actasVeedorProvider(usuario.id));
  }
}

// ─────────────────────────────────────────
// Fila de una acta (alcalde o prefecto)
// ─────────────────────────────────────────
class _FilaActa extends StatelessWidget {
  final Dignidad dignidad;
  final String etiqueta;
  final IconData icono;
  final Acta? acta;
  final VoidCallback onTap;

  const _FilaActa({
    required this.dignidad,
    required this.etiqueta,
    required this.icono,
    required this.acta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(_Tema.cardRadius),
        bottomRight: Radius.circular(_Tema.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: registrada
                    ? _Tema.successContainer
                    : _Tema.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                size: 18,
                color: registrada ? _Tema.success : _Tema.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiqueta,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _Tema.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    registrada
                        ? 'Registrada — toca para editar'
                        : 'Pendiente — toca para registrar',
                    style: TextStyle(
                        fontSize: 11,
                        color: registrada ? _Tema.success : _Tema.greyLight),
                  ),
                ],
              ),
            ),
            _BadgeEstado(acta: acta),
            const SizedBox(width: 8),
            Icon(
              registrada ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 18,
              color: registrada ? _Tema.primary : _Tema.greyLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final Acta? acta;
  const _BadgeEstado({required this.acta});

  @override
  Widget build(BuildContext context) {
    if (acta == null) {
      return _pill('Pendiente', _Tema.warningColor, _Tema.warningContainer);
    }
    return switch (acta!.estado) {
      EstadoActa.ingresada =>
        _pill('Ingresada', _Tema.primary, _Tema.brandAccent),
      EstadoActa.revisada =>
        _pill('Revisada', _Tema.success, _Tema.successContainer),
      EstadoActa.conNovedad =>
        _pill('Con novedad', _Tema.errorColor, _Tema.errorContainer),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold)),
      );
}

// ─────────────────────────────────────────
// Views de estado vacío / error
// ─────────────────────────────────────────
class _SinMesasView extends StatelessWidget {
  const _SinMesasView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: _Tema.greyLight),
            const SizedBox(height: 16),
            const Text(
              'Sin mesas asignadas',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _Tema.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contacta al coordinador de recinto para que te asigne una mesa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _Tema.greyLight),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;

  const _ErrorView({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 48, color: _Tema.errorColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar mesas',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _Tema.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _Tema.greyLight),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style:
                  FilledButton.styleFrom(backgroundColor: _Tema.primary),
            ),
          ],
        ),
      ),
    );
  }
}