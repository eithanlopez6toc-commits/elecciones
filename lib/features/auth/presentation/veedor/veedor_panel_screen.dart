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
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel del Veedor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${usuario.nombres} ${usuario.apellidos}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
        error: (e, _) => _ErrorView(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(mesasVeedorProvider(usuario.id)),
        ),
        data: (mesas) {
          if (mesas.isEmpty) {
            return const _SinMesasView();
          }
          return RefreshIndicator(
            color: const Color(0xFF1A237E),
            onRefresh: () async =>
                ref.invalidate(mesasVeedorProvider(usuario.id)),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _ResumenBanner(mesas: mesas, usuarioId: usuario.id),
                const SizedBox(height: 12),
                ...mesas.map(
                  (mesa) => _TarjetaMesa(
                    mesa: mesa,
                    usuario: usuario,
                  ),
                ),
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
// Banner de resumen
// ─────────────────────────────────────────
class _ResumenBanner extends ConsumerWidget {
  final List<MesaJrv> mesas;
  final String usuarioId;

  const _ResumenBanner({required this.mesas, required this.usuarioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasVeedorProvider(usuarioId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: actasAsync.when(
        loading: () => const SizedBox(
          height: 48,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (actas) {
          final totalEsperadas = mesas.length * 2; // alcalde + prefecto
          final registradas = actas.length;
          final pendientes = totalEsperadas - registradas;

          return Row(
            children: [
              Expanded(
                child: _StatItem(
                  valor: '${mesas.length}',
                  etiqueta: 'Mesas asignadas',
                  icono: Icons.how_to_vote_outlined,
                ),
              ),
              _Divisor(),
              Expanded(
                child: _StatItem(
                  valor: '$registradas',
                  etiqueta: 'Actas registradas',
                  icono: Icons.check_circle_outline,
                ),
              ),
              _Divisor(),
              Expanded(
                child: _StatItem(
                  valor: '$pendientes',
                  etiqueta: 'Pendientes',
                  icono: Icons.pending_outlined,
                  destacar: pendientes > 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final IconData icono;
  final bool destacar;

  const _StatItem({
    required this.valor,
    required this.etiqueta,
    required this.icono,
    this.destacar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: destacar ? const Color(0xFFFFCC02) : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          etiqueta,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado de la mesa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EAF6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_restaurant_outlined,
                    size: 16, color: Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa ${mesa.numeroMesa} — ${mesa.genero}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
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
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: $e',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                      context,
                      ref,
                      Dignidad.alcalde,
                      actaAlcalde,
                    ),
                  ),
                  Divider(
                      height: 1, thickness: 0.5, color: Colors.grey.shade200),
                  _FilaActa(
                    dignidad: Dignidad.prefecto,
                    etiqueta: 'Acta de Prefecto',
                    icono: Icons.account_balance_outlined,
                    acta: actaPrefecto,
                    onTap: () => _navegarAFormulario(
                      context,
                      ref,
                      Dignidad.prefecto,
                      actaPrefecto,
                    ),
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
    // Cargar organizaciones políticas para esa dignidad
    final orgsAsync = ref.read(organizacionesPorDignidadProvider(dignidad));
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
        ),
      ),
    );

    // Refrescar actas de esta mesa al volver
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
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: registrada
                    ? Colors.green.shade50
                    : const Color(0xFFF3F4FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                size: 18,
                color: registrada
                    ? Colors.green.shade600
                    : const Color(0xFF5C6BC0),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    registrada
                        ? 'Registrada — toca para editar'
                        : 'Pendiente — toca para registrar',
                    style: TextStyle(
                      fontSize: 11,
                      color: registrada
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            _BadgeEstado(acta: acta),
            const SizedBox(width: 8),
            Icon(
              registrada ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 18,
              color: registrada
                  ? const Color(0xFF1A237E)
                  : Colors.grey.shade400,
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          'Pendiente',
          style: TextStyle(
              fontSize: 10,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500),
        ),
      );
    }

    final (color, bg, borde, label) = switch (acta!.estado) {
      EstadoActa.ingresada => (
          Colors.blue.shade700,
          Colors.blue.shade50,
          Colors.blue.shade200,
          'Ingresada'
        ),
      EstadoActa.revisada => (
          Colors.green.shade700,
          Colors.green.shade50,
          Colors.green.shade200,
          'Revisada'
        ),
      EstadoActa.conNovedad => (
          Colors.red.shade700,
          Colors.red.shade50,
          Colors.red.shade200,
          'Con novedad'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borde),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Sin mesas asignadas',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta al coordinador de recinto para que te asigne una mesa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar mesas',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E)),
            ),
          ],
        ),
      ),
    );
  }
}