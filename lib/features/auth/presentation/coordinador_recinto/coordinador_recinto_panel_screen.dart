// lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/cedula_validator.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../domain/entities/usuario.dart';
import '../controller/login_controller.dart';
import '../veedor/acta_form_screen.dart';
import '../veedor/veedor_providers.dart';
import 'coordinador_recinto_providers.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN SYSTEM
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
  static const purple = Color(0xFF7C3AED);
  static const purpleContainer = Color(0xFFF5F3FF);
}

// ═════════════════════════════════════════════════════════════════════════════
// DIÁLOGOS REUTILIZABLES
// ═════════════════════════════════════════════════════════════════════════════
void _mostrarErrorDialog(BuildContext context, String mensaje,
    {String titulo = 'Ocurrió un error'}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Tema.cardRadius)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: _Tema.errorContainer,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.error_outline,
              color: _Tema.errorColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(titulo,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurface)),
        ),
      ]),
      content: Text(mensaje,
          style: const TextStyle(
              fontSize: 13, color: _Tema.onSurfaceVariant, height: 1.4)),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: _Tema.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendido',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

void _mostrarExitoDialog(BuildContext context, String mensaje,
    {VoidCallback? onClose}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Tema.cardRadius)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: _Tema.successContainer,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.check_circle_outline,
              color: _Tema.success, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('Operación exitosa',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurface)),
        ),
      ]),
      content: Text(mensaje,
          style: const TextStyle(
              fontSize: 13, color: _Tema.onSurfaceVariant, height: 1.4)),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: _Tema.success,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          onPressed: () {
            Navigator.pop(ctx);
            onClose?.call();
          },
          child: const Text('Continuar',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

String _mensajeAmigable(String error) {
  final lower = error.toLowerCase();
  if (lower.contains('cedula') || lower.contains('cédula')) {
    return 'La cédula ingresada no es válida o ya está registrada.';
  }
  if (lower.contains('correo') || lower.contains('email')) {
    return 'El correo ingresado no es válido o ya está en uso.';
  }
  if (lower.contains('duplicate') || lower.contains('unique')) {
    return 'Ya existe un registro con estos datos.';
  }
  return error.replaceFirst('Exception: ', '');
}

// ═════════════════════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═════════════════════════════════════════════════════════════════════════════
class CoordinadorRecintoPanelScreen extends ConsumerStatefulWidget {
  const CoordinadorRecintoPanelScreen({super.key});

  @override
  ConsumerState<CoordinadorRecintoPanelScreen> createState() =>
      _CoordinadorRecintoPanelScreenState();
}

class _CoordinadorRecintoPanelScreenState
    extends ConsumerState<CoordinadorRecintoPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider);

    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final recintoId = usuario.recintoId;
    if (recintoId == null) {
      return Scaffold(
        backgroundColor: _Tema.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_off_outlined,
                    size: 48, color: _Tema.greyLight),
                SizedBox(height: 12),
                Text('Sin recinto asignado',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _Tema.onSurface)),
                SizedBox(height: 4),
                Text(
                    'Contacta al coordinador provincial para recibir asignación.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      );
    }

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
        title: Row(children: [
          const Icon(Icons.shield_outlined, color: _Tema.primary, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Portal Electoral Seguro',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _Tema.primary)),
                Text(
                    'Coordinador del Recinto: ${usuario.nombres} ${usuario.apellidos}',
                    style: const TextStyle(
                        fontSize: 11, color: _Tema.onSurfaceVariant)),
              ],
            ),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                size: 20, color: _Tema.onSurfaceVariant),
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: _Tema.primary,
            indicatorWeight: 3,
            labelColor: _Tema.primary,
            unselectedLabelColor: _Tema.onSurfaceVariant,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(
                  icon: Icon(Icons.grid_view_outlined, size: 20),
                  text: 'Mesas'),
              Tab(icon: Icon(Icons.badge_outlined, size: 20), text: 'Veedores'),
              Tab(
                  icon: Icon(Icons.swap_horiz_outlined, size: 20),
                  text: 'Reasignar'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TabMesas(recintoId: recintoId, usuario: usuario),
              _TabVeedores(recintoId: recintoId, usuario: usuario),
              _TabReasignar(recintoId: recintoId),
            ],
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — MESAS
// Sin botón "Ir a veedores". Barra de progreso en KPIs y en recuadro pendiente.
// Solo puede actualizar actas (soloLectura=true → coordinador puede corregir).
// ═════════════════════════════════════════════════════════════════════════════
class _TabMesas extends ConsumerWidget {
  final int recintoId;
  final Usuario usuario;

  const _TabMesas({required this.recintoId, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenRecintoProvider(recintoId));
    final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));
    final veedoresAsync = ref.watch(veedoresDeRecintoProvider(recintoId));

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async {
        ref.invalidate(resumenRecintoProvider(recintoId));
        ref.invalidate(mesasPorRecintoProvider(recintoId));
        ref.invalidate(veedoresDeRecintoProvider(recintoId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── KPIs con barra de progreso ───────────────────────────────────
          resumenAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => const SizedBox(),
            data: (r) {
              final totalActas = r.totalMesas * 2;
              final actasIngresadas =
                  r.mesasConActaAlcalde + r.mesasConActaPrefecto;
              final progreso =
                  totalActas > 0 ? actasIngresadas / totalActas : 0.0;
              final progresoAlcalde =
                  r.totalMesas > 0 ? r.mesasConActaAlcalde / r.totalMesas : 0.0;
              final progresoPrefecto = r.totalMesas > 0
                  ? r.mesasConActaPrefecto / r.totalMesas
                  : 0.0;

              return Column(children: [
                // Total mesas
                _CardKPI(
                  label: 'TOTAL MESAS',
                  value: '${r.totalMesas}',
                  icon: Icons.grid_on_outlined,
                  progreso: progreso,
                  progresoLabel:
                      '$actasIngresadas de $totalActas actas completas',
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _CardKPI(
                      label: 'ACTAS ALCALDE',
                      value: '${r.mesasConActaAlcalde}',
                      icon: Icons.how_to_vote_outlined,
                      progreso: progresoAlcalde,
                      progresoLabel:
                          '${r.mesasConActaAlcalde} / ${r.totalMesas}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CardKPI(
                      label: 'ACTAS PREFECTO',
                      value: '${r.mesasConActaPrefecto}',
                      icon: Icons.how_to_vote_outlined,
                      progreso: progresoPrefecto,
                      progresoLabel:
                          '${r.mesasConActaPrefecto} / ${r.totalMesas}',
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                // Pendientes con barra
                _CardKPI(
                  label: 'PENDIENTES',
                  value: '${r.actasPendientes}',
                  icon: Icons.pending_actions_outlined,
                  valueColor:
                      r.actasPendientes > 0 ? _Tema.errorColor : _Tema.success,
                  progreso: totalActas > 0 ? actasIngresadas / totalActas : 0.0,
                  progresoLabel:
                      '$actasIngresadas de $totalActas actas ingresadas',
                  progresoColor:
                      r.actasPendientes > 0 ? _Tema.errorColor : _Tema.success,
                ),
              ]);
            },
          ),
          const SizedBox(height: 16),

          // ── Mesas sin veedor ─────────────────────────────────────────────
          mesasAsync.when(
            loading: () => const SizedBox(),
            error: (e, _) => const SizedBox(),
            data: (mesas) => veedoresAsync.when(
              loading: () => const SizedBox(),
              error: (e, _) => const SizedBox(),
              data: (veedores) {
                final mesaIdsConVeedor = veedores
                    .where((v) => v.mesaId != null)
                    .map((v) => v.mesaId)
                    .toSet();
                final sinVeedor = mesas
                    .where((m) => !mesaIdsConVeedor.contains(m.id))
                    .toList();

                if (sinVeedor.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: _Tema.warningContainer,
                          borderRadius: BorderRadius.circular(_Tema.cardRadius),
                          border: Border.all(
                              color: _Tema.warningColor.withOpacity(0.3))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 18, color: _Tema.warningColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mesas sin veedor asignado (${sinVeedor.length})',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _Tema.warningColor),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            const Text(
                              'Toca una mesa para asignarle un veedor disponible.',
                              style: TextStyle(
                                  fontSize: 11, color: _Tema.onSurfaceVariant),
                            ),
                            const SizedBox(height: 10),
                            ...sinVeedor.map((m) => InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (ctx) =>
                                        _DialogoReasignar(mesa: m),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(children: [
                                      const Icon(Icons.how_to_vote_outlined,
                                          size: 16, color: _Tema.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Mesa ${m.numeroMesa.toString().padLeft(3, '0')} — ${m.genero.dbValue}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const Text('Asignar',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: _Tema.primary,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.chevron_right,
                                          size: 16, color: _Tema.primary),
                                    ]),
                                  ),
                                )),
                          ]),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),

          // ── Listado de mesas ─────────────────────────────────────────────
          const Text('Listado de Mesas',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurfaceVariant)),
          const SizedBox(height: 8),
          mesasAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: _Tema.errorColor))),
            data: (mesas) {
              if (mesas.isEmpty) {
                return const _EmptyState(
                  icono: Icons.table_rows_outlined,
                  mensaje: 'Sin mesas asignadas',
                  sub:
                      'El coordinador provincial aún no ha registrado mesas para este recinto.',
                );
              }
              return Column(
                  children: mesas
                      .map((m) => _TarjetaMesa(mesa: m, usuario: usuario))
                      .toList());
            },
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA DE MESA — expandible, solo actualizar actas (soloLectura para coord)
// ═════════════════════════════════════════════════════════════════════════════
class _TarjetaMesa extends ConsumerStatefulWidget {
  final MesaJrv mesa;
  final Usuario usuario;
  const _TarjetaMesa({required this.mesa, required this.usuario});

  @override
  ConsumerState<_TarjetaMesa> createState() => _TarjetaMesaState();
}

class _TarjetaMesaState extends ConsumerState<_TarjetaMesa> {
  bool _expandida = false;

  @override
  Widget build(BuildContext context) {
    final actasAsync = ref.watch(actasDeMesaProvider(widget.mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(
              color:
                  _expandida ? _Tema.primary.withOpacity(0.3) : _Tema.outline)),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(_Tema.cardRadius),
            bottom: Radius.circular(_expandida ? 0 : _Tema.cardRadius),
          ),
          onTap: () => setState(() => _expandida = !_expandida),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _expandida ? _Tema.brandAccent : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(_Tema.cardRadius),
                bottom: Radius.circular(_expandida ? 0 : _Tema.cardRadius),
              ),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _expandida ? Colors.white : _Tema.brandAccent,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.how_to_vote_outlined,
                    size: 18, color: _Tema.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesa ${widget.mesa.numeroMesa.toString().padLeft(3, '0')}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _Tema.onSurface),
                      ),
                      Text(widget.mesa.genero.dbValue,
                          style: const TextStyle(
                              fontSize: 12, color: _Tema.onSurfaceVariant)),
                    ]),
              ),
              actasAsync.when(
                loading: () => const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const SizedBox(),
                data: (actas) {
                  final tieneAlcalde =
                      actas.any((a) => a.dignidad == Dignidad.alcalde);
                  final tienePrefecto =
                      actas.any((a) => a.dignidad == Dignidad.prefecto);
                  final completa = tieneAlcalde && tienePrefecto;
                  return _pill(
                    completa ? 'Completa' : 'Pendiente',
                    completa ? _Tema.success : _Tema.warningColor,
                    completa ? _Tema.successContainer : _Tema.warningContainer,
                  );
                },
              ),
              const SizedBox(width: 8),
              Icon(
                _expandida
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: _Tema.greyLight,
                size: 20,
              ),
            ]),
          ),
        ),
        if (_expandida)
          actasAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e',
                    style: const TextStyle(color: _Tema.errorColor))),
            data: (actas) {
              final actaAlcalde = actas
                  .where((a) => a.dignidad == Dignidad.alcalde)
                  .firstOrNull;
              final actaPrefecto = actas
                  .where((a) => a.dignidad == Dignidad.prefecto)
                  .firstOrNull;
              return Column(children: [
                Container(height: 1, color: _Tema.outline),
                _FilaActa(
                  etiqueta: 'Acta de Alcalde',
                  acta: actaAlcalde,
                  // Solo permite ir al formulario si ya existe acta
                  onTap: actaAlcalde != null
                      ? () => _irAFormulario(
                          context, ref, Dignidad.alcalde, actaAlcalde)
                      : null,
                ),
                Container(height: 1, color: _Tema.outline),
                _FilaActa(
                  etiqueta: 'Acta de Prefecto',
                  acta: actaPrefecto,
                  onTap: actaPrefecto != null
                      ? () => _irAFormulario(
                          context, ref, Dignidad.prefecto, actaPrefecto)
                      : null,
                ),
              ]);
            },
          ),
      ]),
    );
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      );

  Future<void> _irAFormulario(BuildContext context, WidgetRef ref,
      Dignidad dignidad, Acta actaExistente) async {
    try {
      final List<OrganizacionPolitica> orgs =
          await ref.read(organizacionesPorDignidadProvider(dignidad).future);

      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActaFormScreen(
            mesaId: widget.mesa.id,
            mesaNombre: widget.mesa.numeroMesa.toString(),
            recintoNombre: 'Recinto ${widget.mesa.recintoId}',
            dignidad: dignidad,
            totalSufragantes: actaExistente.totalSufragantes ?? 300,
            organizaciones: orgs,
            userId: widget.usuario.id,
            actaExistente: actaExistente,
            // El coordinador siempre entra en modo solo lectura/corrección
            soloLectura: true,
          ),
        ),
      );
      ref.invalidate(actasDeMesaProvider(widget.mesa.id));
      ref.invalidate(resumenRecintoProvider(widget.mesa.recintoId));
    } catch (e) {
      if (context.mounted) {
        _mostrarErrorDialog(
            context, 'No se pudo abrir el formulario del acta.\n\n$e');
      }
    }
  }
}

// ── Fila de acta: bloqueada si no existe acta (coord no registra) ────────────
class _FilaActa extends StatelessWidget {
  final String etiqueta;
  final Acta? acta;
  final VoidCallback? onTap; // null → no hay acta aún, no se puede tocar

  const _FilaActa(
      {required this.etiqueta, required this.acta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    final tappable = onTap != null;

    return InkWell(
      onTap: tappable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(
            registrada ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: registrada ? _Tema.success : _Tema.greyLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(etiqueta,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _Tema.onSurface)),
              Text(
                registrada
                    ? 'Toca para revisar / actualizar'
                    : 'El veedor aún no ha ingresado esta acta',
                style: TextStyle(
                    fontSize: 11,
                    color: tappable ? _Tema.onSurfaceVariant : _Tema.greyLight),
              ),
            ]),
          ),
          _BadgeActa(acta: acta),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right,
              size: 20, color: tappable ? _Tema.greyLight : _Tema.outline),
        ]),
      ),
    );
  }
}

class _BadgeActa extends StatelessWidget {
  final Acta? acta;
  const _BadgeActa({required this.acta});

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
        _pill('Novedad', _Tema.errorColor, _Tema.errorContainer),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — VEEDORES
// Botón "Agregar Veedor" arriba a la derecha.
// Modal tipo bottom-sheet igual al login.
// 3 secciones: Disponibles / Asignados / Reasignados.
// Límite de 4 veedores por mesa.
// ═════════════════════════════════════════════════════════════════════════════
class _TabVeedores extends ConsumerStatefulWidget {
  final int recintoId;
  final Usuario usuario;

  const _TabVeedores({required this.recintoId, required this.usuario});

  @override
  ConsumerState<_TabVeedores> createState() => _TabVeedoresState();
}

class _TabVeedoresState extends ConsumerState<_TabVeedores> {
  final ctrlCedula = TextEditingController();
  final ctrlNombre = TextEditingController();
  final ctrlApellido = TextEditingController();
  final ctrlTelefono = TextEditingController();
  final ctrlCorreo = TextEditingController();
  int? _mesaIdSeleccionada;
  bool _guardando = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    ctrlCedula.dispose();
    ctrlNombre.dispose();
    ctrlApellido.dispose();
    ctrlTelefono.dispose();
    ctrlCorreo.dispose();
    super.dispose();
  }

  void _limpiar() {
    ctrlCedula.clear();
    ctrlNombre.clear();
    ctrlApellido.clear();
    ctrlTelefono.clear();
    ctrlCorreo.clear();
    setState(() => _mesaIdSeleccionada = null);
    _formKey.currentState?.reset();
  }

  Future<void> _guardarVeedor(BuildContext sheetContext) async {
    if (!_formKey.currentState!.validate()) {
      _mostrarErrorDialog(
        context,
        'Todos los campos son obligatorios y deben tener un formato válido.',
        titulo: 'Formulario incompleto',
      );
      return;
    }
    if (_mesaIdSeleccionada == null) {
      _mostrarErrorDialog(
        context,
        'Debes seleccionar una mesa (JRV) para asignar al veedor.',
        titulo: 'Mesa no seleccionada',
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await ref.read(crearVeedorProvider)(
        ctrlCedula.text.trim(),
        ctrlNombre.text.trim(),
        ctrlApellido.text.trim(),
        ctrlTelefono.text.trim(),
        ctrlCorreo.text.trim(),
        _mesaIdSeleccionada!,
      );
      ref.invalidate(veedoresDeRecintoProvider(widget.recintoId));
      ref.invalidate(mesasPorRecintoProvider(widget.recintoId));
      _limpiar();
      if (context.mounted) {
        Navigator.pop(sheetContext); // cierra el bottom sheet
        _mostrarExitoDialog(
          context,
          'Veedor registrado correctamente. Se envió un correo de confirmación con sus credenciales de acceso.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarErrorDialog(context, _mensajeAmigable(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _abrirBottomSheetAgregarVeedor() {
    final mesasAsync = ref.read(mesasPorRecintoProvider(widget.recintoId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setStateSheet) => Container(
          // ★ FIX: limita la altura para que se vea como bottom sheet real
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E7EC),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Registrar nuevo veedor',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _Tema.onSurface)),
                const SizedBox(height: 4),
                const Text(
                    'Completa los datos para dar de alta al nuevo veedor electoral. Límite: 4 veedores por mesa.',
                    style:
                        TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    _CampoForm(
                      ctrl: ctrlCedula,
                      label: 'Cédula de Identidad',
                      icono: Icons.badge_outlined,
                      hint: 'Ej: 0000000000 (10 dígitos)',
                      digitsOnly: true,
                      maxLength: 10,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return CedulaValidator.validate(v);
                      },
                    ),
                    const SizedBox(height: 14),
                    _CampoForm(
                      ctrl: ctrlNombre,
                      label: 'Nombres Completos',
                      icono: Icons.person_outline,
                      hint: 'Ej: Juan Andrés',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Este campo es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _CampoForm(
                      ctrl: ctrlApellido,
                      label: 'Apellidos Completos',
                      icono: Icons.person_outline,
                      hint: 'Ej: Pérez García',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Este campo es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _CampoForm(
                      ctrl: ctrlTelefono,
                      label: 'Teléfono de Contacto',
                      icono: Icons.phone_outlined,
                      hint: 'Ej: 0999999999',
                      digitsOnly: true,
                      maxLength: 10,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        if (v.length < 9) return 'Teléfono inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _CampoForm(
                      ctrl: ctrlCorreo,
                      label: 'Correo Electrónico',
                      icono: Icons.mail_outline,
                      hint: 'usuario@correo.com',
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(v.trim())) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.grid_view_outlined,
                              size: 14, color: _Tema.onSurfaceVariant),
                          const SizedBox(width: 6),
                          const Text('Mesa a Asignar (JRV)',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _Tema.onSurfaceVariant)),
                          const SizedBox(width: 4),
                          const Text('*',
                              style: TextStyle(
                                  color: _Tema.errorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ]),
                        const SizedBox(height: 6),
                        mesasAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (mesas) => DropdownButtonFormField<int>(
                            value: _mesaIdSeleccionada,
                            hint: const Text(
                                'Seleccione una mesa disponible...',
                                style: TextStyle(fontSize: 13)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: _Tema.outline)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: _Tema.outline)),
                            ),
                            items: mesas
                                .map((m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text(
                                          'Mesa ${m.numeroMesa} — ${m.genero.dbValue}',
                                          style: const TextStyle(fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setStateSheet(() => _mesaIdSeleccionada = v),
                            validator: (v) =>
                                v == null ? 'Selecciona una mesa' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: _Tema.brandAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _Tema.primary.withOpacity(0.1))),
                      child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 18, color: _Tema.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Se enviará una invitación de acceso seguro al correo proporcionado. Máximo 4 veedores por mesa.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _Tema.primary,
                                    height: 1.4),
                              ),
                            ),
                          ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _Tema.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _guardando ? null : () => _guardarVeedor(sheetCtx),
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.assignment_ind_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Finalizar Registro',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Tema.onSurfaceVariant,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: _Tema.outline),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    _limpiar();
                    Navigator.pop(sheetCtx);
                  },
                  child: const Text('Cancelar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final veedoresAsync =
        ref.watch(veedoresDeRecintoProvider(widget.recintoId));

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async =>
          ref.invalidate(veedoresDeRecintoProvider(widget.recintoId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header con botón Agregar arriba ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Veedores del recinto',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _Tema.onSurface)),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _Tema.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: _abrirBottomSheetAgregarVeedor,
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Agregar',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Lista de veedores ─────────────────────────────────────────────
          veedoresAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: _Tema.errorColor))),
            data: (veedores) {
              if (veedores.isEmpty) {
                return _EmptyState(
                  icono: Icons.badge_outlined,
                  mensaje: 'Sin veedores registrados',
                  sub: 'Agrega el primero con el botón superior.',
                  boton: 'Agregar Veedor',
                  onTap: _abrirBottomSheetAgregarVeedor,
                );
              }

              final disponibles = veedores.where((v) => v.disponible).toList();
              final asignados = veedores
                  .where((v) => !v.disponible && !v.reasignado)
                  .toList();
              final reasignados = veedores.where((v) => v.reasignado).toList();

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (disponibles.isNotEmpty) ...[
                      _SeccionHeader(
                          texto: 'Disponibles',
                          color: _Tema.success,
                          count: disponibles.length),
                      const SizedBox(height: 8),
                      ...disponibles.map((v) => _TarjetaVeedor(
                          veedor: v, recintoId: widget.recintoId)),
                      const SizedBox(height: 16),
                    ],
                    if (asignados.isNotEmpty) ...[
                      _SeccionHeader(
                          texto: 'Asignados',
                          color: _Tema.warningColor,
                          count: asignados.length),
                      const SizedBox(height: 8),
                      ...asignados.map((v) => _TarjetaVeedor(
                          veedor: v, recintoId: widget.recintoId)),
                      const SizedBox(height: 16),
                    ],
                    if (reasignados.isNotEmpty) ...[
                      _SeccionHeader(
                          texto: 'Reasignados',
                          color: _Tema.purple,
                          count: reasignados.length),
                      const SizedBox(height: 8),
                      ...reasignados.map((v) => _TarjetaVeedor(
                          veedor: v, recintoId: widget.recintoId)),
                    ],
                  ]);
            },
          ),
        ],
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  final String texto;
  final Color color;
  final int count;
  const _SeccionHeader(
      {required this.texto, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(texto.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _Tema.onSurfaceVariant,
              letterSpacing: 0.5)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Text('$count',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ),
    ]);
  }
}

class _TarjetaVeedor extends ConsumerWidget {
  final VeedorConMesa veedor;
  final int recintoId;
  const _TarjetaVeedor({required this.veedor, required this.recintoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = veedor.usuario;
    final disponible = veedor.disponible;
    final reasignado = veedor.reasignado;

    Color avatarBg = _Tema.brandAccent;
    Color avatarFg = _Tema.primary;
    Color pillBg = _Tema.successContainer;
    Color pillFg = _Tema.success;
    String pillLabel = 'Disponible';

    if (reasignado) {
      avatarBg = _Tema.purpleContainer;
      avatarFg = _Tema.purple;
      pillBg = _Tema.purpleContainer;
      pillFg = _Tema.purple;
      pillLabel = 'Reasignado';
    } else if (!disponible) {
      pillBg = _Tema.warningContainer;
      pillFg = _Tema.warningColor;
      pillLabel = 'Asignado';
    }

    // Solo se puede eliminar si aún no tiene mesa asignada (no registrado/activo)
    final puedeEliminar = disponible;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: avatarBg,
          child: Text(u.nombres.isNotEmpty ? u.nombres[0].toUpperCase() : '?',
              style: TextStyle(
                  color: avatarFg, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${u.nombres} ${u.apellidos}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _Tema.onSurface)),
            const SizedBox(height: 2),
            Text('C.C: ${u.cedula}',
                style: const TextStyle(
                    fontSize: 11, color: _Tema.onSurfaceVariant)),
            if (u.correo.isNotEmpty)
              Text(u.correo,
                  style: const TextStyle(fontSize: 11, color: _Tema.greyLight)),
            if (!disponible && veedor.numeroMesa != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  reasignado
                      ? 'Reasignado → Mesa ${veedor.numeroMesa}'
                      : 'Mesa ${veedor.numeroMesa}',
                  style: TextStyle(
                      fontSize: 11,
                      color: reasignado ? _Tema.purple : _Tema.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(pillLabel,
              style: TextStyle(
                  fontSize: 10, color: pillFg, fontWeight: FontWeight.bold)),
        ),
        if (puedeEliminar) ...[
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: _Tema.errorColor),
            tooltip: 'Eliminar veedor',
            onPressed: () => _confirmarEliminar(context, ref, u),
          ),
        ],
      ]),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Usuario u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_Tema.cardRadius)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _Tema.errorContainer,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.delete_outline,
                color: _Tema.errorColor, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('¿Eliminar veedor?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _Tema.onSurface)),
          ),
        ]),
        content: Text(
          'Se eliminará a ${u.nombres} ${u.apellidos} (C.C: ${u.cedula}). '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(
              fontSize: 13, color: _Tema.onSurfaceVariant, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: _Tema.onSurfaceVariant,
                side: const BorderSide(color: _Tema.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: _Tema.errorColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(eliminarVeedorProvider)(u.id);
                ref.invalidate(veedoresDeRecintoProvider(recintoId));
                ref.invalidate(mesasPorRecintoProvider(recintoId));
              } catch (e) {
                if (context.mounted) {
                  _mostrarErrorDialog(
                      context, 'No se pudo eliminar al veedor.\n\n$e');
                }
              }
            },
            child: const Text('Sí, eliminar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — REASIGNAR
// ═════════════════════════════════════════════════════════════════════════════
class _TabReasignar extends ConsumerWidget {
  final int recintoId;
  const _TabReasignar({required this.recintoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async => ref.invalidate(mesasPorRecintoProvider(recintoId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Gestión de Mesas',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurfaceVariant)),
          const SizedBox(height: 8),
          mesasAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: _Tema.errorColor))),
            data: (mesas) {
              if (mesas.isEmpty) {
                return const _EmptyState(
                  icono: Icons.swap_horiz_outlined,
                  mensaje: 'Sin mesas disponibles',
                  sub:
                      'El coordinador provincial aún no ha registrado mesas para este recinto.',
                );
              }
              return Column(
                  children:
                      mesas.map((m) => _TarjetaReasignacion(mesa: m)).toList());
            },
          ),
        ],
      ),
    );
  }
}

class _TarjetaReasignacion extends StatelessWidget {
  final MesaJrv mesa;
  const _TarjetaReasignacion({required this.mesa});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: InkWell(
        borderRadius: BorderRadius.circular(_Tema.cardRadius),
        onTap: () => showDialog(
            context: context, builder: (ctx) => _DialogoReasignar(mesa: mesa)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _Tema.brandAccent,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.how_to_vote_outlined,
                  size: 20, color: _Tema.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mesa ${mesa.numeroMesa.toString().padLeft(3, '0')}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _Tema.onSurface)),
                    Text(mesa.genero.dbValue,
                        style: const TextStyle(
                            fontSize: 12, color: _Tema.onSurfaceVariant)),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: _Tema.brandAccent,
                  borderRadius: BorderRadius.circular(6)),
              child: const Row(children: [
                Icon(Icons.swap_horiz, size: 14, color: _Tema.primary),
                SizedBox(width: 4),
                Text('Reasignar',
                    style: TextStyle(
                        fontSize: 11,
                        color: _Tema.primary,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DIÁLOGO REASIGNAR — solo veedores disponibles
// Al confirmar, el veedor pasa a estado "reasignado" en la lista
// ═════════════════════════════════════════════════════════════════════════════
class _DialogoReasignar extends ConsumerStatefulWidget {
  final MesaJrv mesa;
  const _DialogoReasignar({required this.mesa});

  @override
  ConsumerState<_DialogoReasignar> createState() => _DialogoReasignarState();
}

class _DialogoReasignarState extends ConsumerState<_DialogoReasignar> {
  String? _veedorSeleccionado;
  bool _guardando = false;

  @override
  Widget build(BuildContext context) {
    final veedoresAsync =
        ref.watch(veedoresDeRecintoProvider(widget.mesa.recintoId));

    return AlertDialog(
      backgroundColor: _Tema.background,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Tema.cardRadius)),
      title: Column(children: [
        const Icon(Icons.swap_horiz_outlined, size: 36, color: _Tema.primary),
        const SizedBox(height: 8),
        Text('Asignar / Reasignar Veedor\nMesa ${widget.mesa.numeroMesa}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _Tema.onSurface)),
      ]),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_Tema.cardRadius),
            border: Border.all(color: _Tema.outline)),
        child: veedoresAsync.when(
          loading: () => const SizedBox(
              height: 60, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
          data: (veedores) {
            final disponibles = veedores.where((v) => v.disponible).toList();
            if (disponibles.isEmpty) {
              return const Text('No hay veedores disponibles en este recinto.',
                  style: TextStyle(fontSize: 14));
            }
            return DropdownButtonFormField<String>(
              value: _veedorSeleccionado,
              hint: const Text('Seleccionar veedor disponible',
                  style: TextStyle(fontSize: 13)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _Tema.outline)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: disponibles
                  .map((v) => DropdownMenuItem(
                        value: v.usuario.id,
                        child: Text(
                            '${v.usuario.nombres} ${v.usuario.apellidos}',
                            style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _veedorSeleccionado = v),
            );
          },
        ),
      ),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              foregroundColor: _Tema.onSurfaceVariant,
              side: const BorderSide(color: _Tema.outline),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: _Tema.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          onPressed: (_veedorSeleccionado == null || _guardando)
              ? null
              : () async {
                  setState(() => _guardando = true);
                  try {
                    await ref.read(reasignarVeedorProvider)(
                        _veedorSeleccionado!, widget.mesa.id);
                    ref.invalidate(
                        veedoresDeRecintoProvider(widget.mesa.recintoId));
                    ref.invalidate(
                        mesasPorRecintoProvider(widget.mesa.recintoId));
                    if (context.mounted) {
                      Navigator.pop(context);
                      _mostrarExitoDialog(
                          context,
                          'Veedor asignado exitosamente a la Mesa ${widget.mesa.numeroMesa}. '
                          'El veedor aparecerá como "Reasignado" en la lista.');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _mostrarErrorDialog(context,
                          'No se pudo asignar al veedor.\n\n${_mensajeAmigable(e.toString())}');
                    }
                  } finally {
                    if (mounted) setState(() => _guardando = false);
                  }
                },
          child: _guardando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Confirmar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS COMPARTIDOS
// ═════════════════════════════════════════════════════════════════════════════

/// KPI con barra de progreso opcional
class _CardKPI extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final double? progreso;
  final String? progresoLabel;
  final Color? progresoColor;

  const _CardKPI({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.progreso,
    this.progresoLabel,
    this.progresoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: _Tema.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _Tema.greyLight,
                  letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: valueColor ?? _Tema.onSurface)),
        if (progreso != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progreso!.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: _Tema.outline,
              color: progresoColor ?? _Tema.primary,
            ),
          ),
          if (progresoLabel != null) ...[
            const SizedBox(height: 4),
            Text(progresoLabel!,
                style: const TextStyle(
                    fontSize: 9, color: _Tema.onSurfaceVariant)),
          ],
        ],
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String sub;
  final String? boton;
  final VoidCallback? onTap;

  const _EmptyState({
    required this.icono,
    required this.mensaje,
    required this.sub,
    this.boton,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(icono, size: 48, color: _Tema.greyLight),
          const SizedBox(height: 12),
          Text(mensaje,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurface)),
          Text(sub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _Tema.greyLight)),
          if (boton != null && onTap != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: _Tema.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: onTap,
              child: Text(boton!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _Tema.greyLight, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _Tema.outline)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _Tema.outline)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _Tema.primary, width: 1.5)),
    );

class _CampoForm extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData? icono;
  final String hint;
  final bool digitsOnly;
  final int? maxLength;
  final bool obligatorio;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;

  const _CampoForm({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.icono,
    this.digitsOnly = false,
    this.maxLength,
    this.obligatorio = true,
    this.validator,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icono ?? Icons.edit_outlined,
            size: 14, color: _Tema.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _Tema.onSurfaceVariant)),
        if (obligatorio) ...[
          const SizedBox(width: 4),
          const Text('*',
              style: TextStyle(
                  color: _Tema.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ]),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard ??
            (digitsOnly ? TextInputType.number : TextInputType.text),
        inputFormatters: [
          if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: _inputDeco(hint),
        validator: validator ??
            (obligatorio
                ? (v) => (v == null || v.trim().isEmpty)
                    ? 'Este campo es obligatorio'
                    : null
                : null),
      ),
    ]);
  }
}
