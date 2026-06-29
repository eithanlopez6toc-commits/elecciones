// lib/features/auth/presentation/veedor/veedor_panel_screen.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../domain/entities/usuario.dart';
import '../controller/login_controller.dart';
import 'acta_form_screen.dart';
import 'veedor_providers.dart';

class _T {
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
  static const syncColor = Color(0xFF6366F1);
  static const syncContainer = Color(0xFFEEF2FF);
}

class VeedorPanelScreen extends ConsumerStatefulWidget {
  const VeedorPanelScreen({super.key});

  @override
  ConsumerState<VeedorPanelScreen> createState() => _VeedorPanelScreenState();
}

class _VeedorPanelScreenState extends ConsumerState<VeedorPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  StreamSubscription? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && mounted) {
        _sincronizarPendientes();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _sincronizarPendientes() async {
    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) return;
    await ref
        .read(syncPendientesProvider.notifier)
        .sincronizarTodos(userId: usuario.id);
    ref.invalidate(actasVeedorProvider(usuario.id));
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider);
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.listen(syncPendientesProvider, (_, next) {
      if (next.sincronizados > 0) {
        ref.invalidate(actasVeedorProvider(usuario.id));
        ref.invalidate(mesasVeedorProvider(usuario.id));
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
        title: Row(children: [
          const Icon(Icons.shield_outlined, color: _T.primary, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Portal Electoral Seguro',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _T.primary)),
              Text('Veedor: ${usuario.nombres} ${usuario.apellidos}',
                  style: const TextStyle(
                      fontSize: 11, color: _T.onSurfaceVariant)),
            ]),
          ),
        ]),
        actions: [
          _IndicadorSync(),
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                size: 20, color: _T.onSurfaceVariant),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
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
            indicatorColor: _T.primary,
            indicatorWeight: 3,
            labelColor: _T.primary,
            unselectedLabelColor: _T.onSurfaceVariant,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(
                  icon: Icon(Icons.how_to_vote_outlined, size: 20),
                  text: 'Mesas'),
              Tab(
                  icon: Icon(Icons.pending_actions_outlined, size: 20),
                  text: 'Pendientes'),
              Tab(
                  icon: Icon(Icons.check_circle_outline, size: 20),
                  text: 'Completadas'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TabMesas(usuario: usuario),
              _TabActasFiltradas(
                usuario: usuario,
                soloCompletas: false,
                onIrAMesas: () => _tabCtrl.animateTo(0),
              ),
              _TabActasFiltradas(
                usuario: usuario,
                soloCompletas: true,
                onIrAMesas: () => _tabCtrl.animateTo(0),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _IndicadorSync extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncPendientesProvider);
    if (!sync.sincronizando && sync.pendientes == 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: sync.sincronizando ? _T.syncContainer : _T.warningContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (sync.sincronizando)
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _T.syncColor),
              )
            else
              const Icon(Icons.cloud_off, size: 12, color: _T.warningColor),
            const SizedBox(width: 4),
            Text(
              sync.sincronizando
                  ? 'Subiendo…'
                  : '${sync.pendientes} pendiente${sync.pendientes > 1 ? 's' : ''}',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: sync.sincronizando ? _T.syncColor : _T.warningColor),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TabMesas extends ConsumerWidget {
  final Usuario usuario;
  const _TabMesas({required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesasAsync = ref.watch(mesasVeedorProvider(usuario.id));
    final actasAsync = ref.watch(actasVeedorProvider(usuario.id));

    return RefreshIndicator(
      color: _T.primary,
      onRefresh: () async {
        ref.invalidate(mesasVeedorProvider(usuario.id));
        ref.invalidate(actasVeedorProvider(usuario.id));
      },
      child: mesasAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _T.primary)),
        error: (e, _) => _ErrorView(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(mesasVeedorProvider(usuario.id)),
        ),
        data: (mesas) {
          if (mesas.isEmpty) return const _SinMesasView();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              actasAsync.when(
                loading: () => const SizedBox(
                    height: 80,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: _T.primary, strokeWidth: 2))),
                error: (_, __) => const SizedBox.shrink(),
                data: (actas) {
                  final totalEsperadas = mesas.length * 2;
                  final registradas = actas.length;
                  final pendientes = totalEsperadas - registradas;
                  final progreso = totalEsperadas == 0
                      ? 0.0
                      : (registradas / totalEsperadas).clamp(0.0, 1.0);

                  return Column(children: [
                    Row(children: [
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
                          valueColor:
                              pendientes > 0 ? _T.warningColor : _T.success,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _CardKPI(
                      label: 'PROGRESO DE ACTAS',
                      value: '${(progreso * 100).toStringAsFixed(1)}%',
                      icon: Icons.analytics_outlined,
                      progress: progreso,
                    ),
                  ]);
                },
              ),
              const SizedBox(height: 16),
              const Text('Mesas asignadas',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _T.onSurfaceVariant)),
              const SizedBox(height: 8),
              ...mesas.map((m) => _TarjetaMesa(mesa: m, usuario: usuario)),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

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
    final actasAsync = ref.watch(actasPorMesaProvider(widget.mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          border: Border.all(
              color: _expandida ? _T.primary.withOpacity(0.3) : _T.outline)),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(_T.cardRadius),
            bottom: Radius.circular(_expandida ? 0 : _T.cardRadius),
          ),
          onTap: () => setState(() => _expandida = !_expandida),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _expandida ? _T.brandAccent : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(_T.cardRadius),
                bottom: Radius.circular(_expandida ? 0 : _T.cardRadius),
              ),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _expandida ? Colors.white : _T.brandAccent,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.how_to_vote_outlined,
                    size: 18, color: _T.primary),
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
                            color: _T.onSurface),
                      ),
                      Text(widget.mesa.genero.dbValue,
                          style: const TextStyle(
                              fontSize: 12, color: _T.onSurfaceVariant)),
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
                  return _Pill(
                    label: completa ? 'Completa' : 'Pendiente',
                    color: completa ? _T.success : _T.warningColor,
                    bg: completa ? _T.successContainer : _T.warningContainer,
                  );
                },
              ),
              const SizedBox(width: 8),
              Icon(
                _expandida
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: _T.greyLight,
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
                    style: const TextStyle(color: _T.errorColor))),
            data: (actas) {
              final actaAlcalde = actas
                  .where((a) => a.dignidad == Dignidad.alcalde)
                  .firstOrNull;
              final actaPrefecto = actas
                  .where((a) => a.dignidad == Dignidad.prefecto)
                  .firstOrNull;

              return Column(children: [
                Container(height: 1, color: _T.outline),
                _RecuadroDignidad(
                  etiqueta: 'Acta de Alcalde',
                  icono: Icons.location_city_outlined,
                  acta: actaAlcalde,
                  onTap: () => _irAFormulario(
                      context, ref, Dignidad.alcalde, actaAlcalde),
                ),
                Container(height: 1, color: _T.outline),
                _RecuadroDignidad(
                  etiqueta: 'Acta de Prefecto',
                  icono: Icons.account_balance_outlined,
                  acta: actaPrefecto,
                  onTap: () => _irAFormulario(
                      context, ref, Dignidad.prefecto, actaPrefecto),
                ),
              ]);
            },
          ),
      ]),
    );
  }

  Future<void> _irAFormulario(
    BuildContext context,
    WidgetRef ref,
    Dignidad dignidad,
    Acta? actaExistente,
  ) async {
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
          totalSufragantes: 300,
          organizaciones: orgs,
          userId: widget.usuario.id,
          actaExistente: actaExistente,
        ),
      ),
    );

    ref.invalidate(actasPorMesaProvider(widget.mesa.id));
    ref.invalidate(actasVeedorProvider(widget.usuario.id));
  }
}

class _RecuadroDignidad extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final Acta? acta;
  final VoidCallback onTap;

  const _RecuadroDignidad({
    required this.etiqueta,
    required this.icono,
    required this.acta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    final pendienteSync = acta?.pendienteSync ?? false;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: pendienteSync
                  ? _T.syncContainer
                  : registrada
                      ? _T.successContainer
                      : _T.brandAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              size: 20,
              color: pendienteSync
                  ? _T.syncColor
                  : registrada
                      ? _T.success
                      : _T.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(etiqueta,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _T.onSurface)),
              const SizedBox(height: 3),
              Text(
                pendienteSync
                    ? 'Guardada · subiendo al sistema…'
                    : registrada
                        ? 'Registrada · toca para ver o corregir'
                        : 'Pendiente · toca para registrar',
                style: TextStyle(
                  fontSize: 11,
                  color: pendienteSync
                      ? _T.syncColor
                      : registrada
                          ? _T.success
                          : _T.greyLight,
                ),
              ),
            ]),
          ),
          _BadgeEstado(acta: acta),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right, color: _T.greyLight, size: 20),
        ]),
      ),
    );
  }
}

class _TabActasFiltradas extends ConsumerWidget {
  final Usuario usuario;
  final bool soloCompletas;
  final VoidCallback onIrAMesas;

  const _TabActasFiltradas({
    required this.usuario,
    required this.soloCompletas,
    required this.onIrAMesas,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesasAsync = ref.watch(mesasVeedorProvider(usuario.id));
    final actasAsync = ref.watch(actasVeedorProvider(usuario.id));

    return RefreshIndicator(
      color: _T.primary,
      onRefresh: () async {
        ref.invalidate(mesasVeedorProvider(usuario.id));
        ref.invalidate(actasVeedorProvider(usuario.id));
      },
      child: mesasAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _T.primary)),
        error: (e, _) => _ErrorView(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(mesasVeedorProvider(usuario.id)),
        ),
        data: (mesas) => actasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: _T.errorColor))),
          data: (actas) {
            final items = <_ItemActa>[];
            for (final mesa in mesas) {
              for (final dignidad in [Dignidad.alcalde, Dignidad.prefecto]) {
                final acta = actas
                    .where((a) => a.mesaId == mesa.id && a.dignidad == dignidad)
                    .firstOrNull;

                if (soloCompletas) {
                  if (acta != null && !(acta.pendienteSync)) {
                    items.add(
                        _ItemActa(mesa: mesa, dignidad: dignidad, acta: acta));
                  }
                } else {
                  if (acta == null || acta.pendienteSync) {
                    items.add(
                        _ItemActa(mesa: mesa, dignidad: dignidad, acta: acta));
                  }
                }
              }
            }

            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        soloCompletas
                            ? Icons.check_circle_outline
                            : Icons.pending_actions_outlined,
                        size: 56,
                        color: _T.greyLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        soloCompletas
                            ? 'Aún no hay actas completadas'
                            : '¡Todo al día!',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _T.onSurface),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        soloCompletas
                            ? 'Las actas registradas y sincronizadas aparecerán aquí.'
                            : 'No tienes actas pendientes por registrar.',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 13, color: _T.greyLight),
                      ),
                      if (!soloCompletas) ...[
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: _T.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          onPressed: onIrAMesas,
                          icon:
                              const Icon(Icons.how_to_vote_outlined, size: 16),
                          label: const Text('Ver mis mesas'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CardKPI(
                  label:
                      soloCompletas ? 'ACTAS COMPLETADAS' : 'ACTAS PENDIENTES',
                  value: '${items.length}',
                  icon: soloCompletas
                      ? Icons.check_circle_outline
                      : Icons.pending_actions_outlined,
                  valueColor: soloCompletas ? _T.success : _T.warningColor,
                ),
                const SizedBox(height: 16),
                Text(
                  soloCompletas ? 'Actas completadas' : 'Actas pendientes',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _T.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => _TarjetaActaResumen(
                      item: item,
                      usuario: usuario,
                      soloCompleta: soloCompletas,
                      onActualizar: () {
                        ref.invalidate(actasVeedorProvider(usuario.id));
                        ref.invalidate(actasPorMesaProvider(item.mesa.id));
                      },
                    )),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ItemActa {
  final MesaJrv mesa;
  final Dignidad dignidad;
  final Acta? acta;
  const _ItemActa(
      {required this.mesa, required this.dignidad, required this.acta});
}

class _TarjetaActaResumen extends ConsumerWidget {
  final _ItemActa item;
  final Usuario usuario;
  final bool soloCompleta;
  final VoidCallback onActualizar;

  const _TarjetaActaResumen({
    required this.item,
    required this.usuario,
    required this.soloCompleta,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esAlcalde = item.dignidad == Dignidad.alcalde;
    final pendienteSync = item.acta?.pendienteSync ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          border: Border.all(color: _T.outline)),
      child: InkWell(
        borderRadius: BorderRadius.circular(_T.cardRadius),
        onTap: () async {
          final orgs = await ref
              .read(organizacionesPorDignidadProvider(item.dignidad).future);
          if (!context.mounted) return;
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ActaFormScreen(
              mesaId: item.mesa.id,
              mesaNombre: item.mesa.numeroMesa.toString(),
              recintoNombre: 'Recinto ${item.mesa.recintoId}',
              dignidad: item.dignidad,
              totalSufragantes: 300,
              organizaciones: orgs,
              userId: usuario.id,
              actaExistente: item.acta,
            ),
          ));
          onActualizar();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: pendienteSync
                      ? _T.syncContainer
                      : soloCompleta
                          ? _T.successContainer
                          : _T.warningContainer,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(
                esAlcalde
                    ? Icons.location_city_outlined
                    : Icons.account_balance_outlined,
                size: 20,
                color: pendienteSync
                    ? _T.syncColor
                    : soloCompleta
                        ? _T.success
                        : _T.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${item.mesa.numeroMesa.toString().padLeft(3, '0')} — ${item.mesa.genero.dbValue}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _T.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      esAlcalde ? 'Acta de Alcalde' : 'Acta de Prefecto',
                      style: const TextStyle(
                          fontSize: 12, color: _T.onSurfaceVariant),
                    ),
                    if (pendienteSync) ...[
                      const SizedBox(height: 3),
                      const Row(children: [
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _T.syncColor),
                        ),
                        SizedBox(width: 5),
                        Text('Subiendo al sistema…',
                            style: TextStyle(
                                fontSize: 11,
                                color: _T.syncColor,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ] else if (item.acta?.gpsLat != null) ...[
                      const SizedBox(height: 2),
                      const Text('GPS registrado',
                          style: TextStyle(fontSize: 11, color: _T.greyLight)),
                    ],
                  ]),
            ),
            _BadgeEstado(acta: item.acta),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _T.greyLight, size: 20),
          ]),
        ),
      ),
    );
  }
}

class _CardKPI extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final double? progress;
  final Color? valueColor;

  const _CardKPI({
    required this.label,
    required this.value,
    required this.icon,
    this.progress,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          border: Border.all(color: _T.outline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: _T.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _T.greyLight,
                    letterSpacing: 0.5)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: valueColor ?? _T.onSurface)),
        if (progress != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: _T.background,
                color: _T.primary),
          ),
        ],
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Pill({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final Acta? acta;
  const _BadgeEstado({required this.acta});

  @override
  Widget build(BuildContext context) {
    if (acta == null) {
      return _pill('Pendiente', _T.warningColor, _T.warningContainer);
    }
    if (acta!.pendienteSync) {
      return _pill('Subiendo…', _T.syncColor, _T.syncContainer);
    }
    return switch (acta!.estado) {
      EstadoActa.ingresada => _pill('Ingresada', _T.primary, _T.brandAccent),
      EstadoActa.revisada => _pill('Revisada', _T.success, _T.successContainer),
      EstadoActa.conNovedad =>
        _pill('Con novedad', _T.errorColor, _T.errorContainer),
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

class _SinMesasView extends StatelessWidget {
  const _SinMesasView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 64, color: _T.greyLight),
          SizedBox(height: 16),
          Text('Sin mesas asignadas',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _T.onSurfaceVariant)),
          SizedBox(height: 8),
          Text(
            'Contacta al coordinador de recinto para que te asigne una mesa.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _T.greyLight),
          ),
        ]),
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.inbox_outlined, size: 64, color: _T.greyLight),
          const SizedBox(height: 16),
          const Text('Sin mesas asignadas',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _T.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _T.greyLight)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(
                backgroundColor: _T.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
        ]),
      ),
    );
  }
}
