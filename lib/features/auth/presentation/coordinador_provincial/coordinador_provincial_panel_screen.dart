// lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/recinto.dart';
import '../controller/login_controller.dart';
import 'coordinador_provincial_providers.dart';

class CoordinadorProvincialPanelScreen extends ConsumerStatefulWidget {
  const CoordinadorProvincialPanelScreen({super.key});

  @override
  ConsumerState<CoordinadorProvincialPanelScreen> createState() =>
      _CoordinadorProvincialPanelScreenState();
}

class _CoordinadorProvincialPanelScreenState
    extends ConsumerState<CoordinadorProvincialPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Filtro de dignidad en el dashboard
  String _dignidadFiltro = 'Todos';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coordinador Provincial',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (usuario != null)
              Text('${usuario.nombres} ${usuario.apellidos}',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            tooltip: 'Nuevo recinto',
            onPressed: () => _dialogCrearRecinto(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined, size: 20),
            tooltip: 'Nuevo coordinador',
            onPressed: () => _dialogCrearCoordinador(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF7C83F7),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.location_city_outlined, size: 18), text: 'Recintos'),
            Tab(icon: Icon(Icons.bar_chart_outlined, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Coordinadores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TabRecintos(onCrear: () => _dialogCrearRecinto(context)),
          _TabDashboard(
            filtro: _dignidadFiltro,
            onFiltroChanged: (v) => setState(() => _dignidadFiltro = v),
          ),
          const _TabCoordinadores(),
        ],
      ),
    );
  }

  // ── Diálogo crear recinto ──────────────────────────────────────────────────
  void _dialogCrearRecinto(BuildContext context) {
    final ctrlNombre = TextEditingController();
    final ctrlCanton = TextEditingController();
    final ctrlParroquia = TextEditingController();
    final ctrlDireccion = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo recinto electoral',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Campo(ctrl: ctrlNombre, label: 'Nombre del recinto'),
              const SizedBox(height: 10),
              _Campo(ctrl: ctrlCanton, label: 'Cantón'),
              const SizedBox(height: 10),
              _Campo(ctrl: ctrlParroquia, label: 'Parroquia'),
              const SizedBox(height: 10),
              _Campo(ctrl: ctrlDireccion, label: 'Dirección (opcional)'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E)),
            onPressed: () async {
              if (ctrlNombre.text.isEmpty ||
                  ctrlCanton.text.isEmpty ||
                  ctrlParroquia.text.isEmpty) return;
              try {
                await ref.read(crearRecintoProvider)(
                  ctrlCanton.text.trim(),
                  ctrlParroquia.text.trim(),
                  ctrlNombre.text.trim(),
                  ctrlDireccion.text.trim().isEmpty
                      ? null
                      : ctrlDireccion.text.trim(),
                );
                ref.invalidate(todosLosRecintosProvider);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Recinto creado correctamente'),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // ── Diálogo crear coordinador de recinto ──────────────────────────────────
  void _dialogCrearCoordinador(BuildContext context) {
    final ctrlCedula = TextEditingController();
    final ctrlNombres = TextEditingController();
    final ctrlApellidos = TextEditingController();
    final ctrlTelefono = TextEditingController();
    int? recintoIdSeleccionado;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final recintosAsync = ref.watch(todosLosRecintosProvider);
          return AlertDialog(
            title: const Text('Crear coordinador de recinto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Campo(
                      ctrl: ctrlCedula,
                      label: 'Cédula',
                      digitsOnly: true,
                      maxLength: 10),
                  const SizedBox(height: 10),
                  _Campo(ctrl: ctrlNombres, label: 'Nombres'),
                  const SizedBox(height: 10),
                  _Campo(ctrl: ctrlApellidos, label: 'Apellidos'),
                  const SizedBox(height: 10),
                  _Campo(
                      ctrl: ctrlTelefono,
                      label: 'Teléfono',
                      digitsOnly: true),
                  const SizedBox(height: 10),
                  recintosAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (recintos) => DropdownButtonFormField<int>(
                      value: recintoIdSeleccionado,
                      hint: const Text('Asignar a recinto'),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), isDense: true),
                      items: recintos
                          .map((r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.nombre,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setS(() => recintoIdSeleccionado = v),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E)),
                onPressed: recintoIdSeleccionado == null
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(crearCoordinadorRecintoProvider)(
                            ctrlCedula.text.trim(),
                            ctrlNombres.text.trim(),
                            ctrlApellidos.text.trim(),
                            ctrlTelefono.text.trim(),
                            recintoIdSeleccionado!,
                          );
                          ref.invalidate(coordinadoresRecintoProvider);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Coordinador creado'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — RECINTOS
// ═════════════════════════════════════════════════════════════════════════════
class _TabRecintos extends ConsumerWidget {
  final VoidCallback onCrear;
  const _TabRecintos({required this.onCrear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recintosAsync = ref.watch(todosLosRecintosProvider);

    return RefreshIndicator(
      color: const Color(0xFF1A237E),
      onRefresh: () async => ref.invalidate(todosLosRecintosProvider),
      child: recintosAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (recintos) {
          if (recintos.isEmpty) {
            return _EmptyState(
              icono: Icons.location_city_outlined,
              mensaje: 'Sin recintos registrados',
              sub: 'Crea el primer recinto electoral.',
              boton: 'Crear recinto',
              onTap: onCrear,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: recintos.length,
            itemBuilder: (_, i) =>
                _TarjetaRecinto(recinto: recintos[i]),
          );
        },
      ),
    );
  }
}

class _TarjetaRecinto extends ConsumerWidget {
  final Recinto recinto;
  const _TarjetaRecinto({required this.recinto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync =
        ref.watch(resumenPorRecintoProvider(recinto));

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
              offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _verDetalle(context, recinto),
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8EAF6),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city_outlined,
                      size: 16, color: Color(0xFF1A237E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recinto.nombre,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A237E)),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 16, color: Color(0xFF1A237E)),
                ],
              ),
            ),
            // Sub-info
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 13, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text(
                    '${recinto.canton} · ${recinto.parroquia}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575)),
                  ),
                  const Spacer(),
                  resumenAsync.when(
                    loading: () => const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const SizedBox(),
                    data: (r) => _PillAvance(resumen: r),
                  ),
                ],
              ),
            ),
            // Barra de progreso
            resumenAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (r) => r.totalMesas == 0
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: r.porcentaje,
                              minHeight: 6,
                              backgroundColor:
                                  const Color(0xFFE8EAF6),
                              color: r.porcentaje == 1
                                  ? Colors.green
                                  : const Color(0xFF3949AB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.totalActas} / ${r.totalMesas * 2} actas · ${r.totalMesas} mesas',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF9E9E9E)),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalle(BuildContext context, Recinto recinto) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _DetalleRecintoScreen(recinto: recinto),
    ));
  }
}

class _PillAvance extends StatelessWidget {
  final ResumenRecintoProv resumen;
  const _PillAvance({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final color = resumen.pendientes == 0
        ? Colors.green.shade600
        : resumen.porcentaje > 0.5
            ? Colors.blue.shade600
            : Colors.orange.shade700;
    final bg = resumen.pendientes == 0
        ? Colors.green.shade50
        : resumen.porcentaje > 0.5
            ? Colors.blue.shade50
            : Colors.orange.shade50;
    final label = resumen.pendientes == 0
        ? 'Completo'
        : '${resumen.pendientes} pendientes';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Detalle de un recinto (actas con GPS) ───────────────────────────────────
class _DetalleRecintoScreen extends ConsumerWidget {
  final Recinto recinto;
  const _DetalleRecintoScreen({required this.recinto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasDeRecintoProvider(recinto.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text(recinto.nombre,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => ref.invalidate(actasDeRecintoProvider(recinto.id)),
          ),
        ],
      ),
      body: actasAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (actas) {
          if (actas.isEmpty) {
            return const Center(
              child: Text('Sin actas registradas en este recinto.',
                  style: TextStyle(color: Color(0xFF9E9E9E))),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: actas.length,
            itemBuilder: (_, i) => _TarjetaActaDetalle(acta: actas[i]),
          );
        },
      ),
    );
  }
}

class _TarjetaActaDetalle extends StatelessWidget {
  final Acta acta;
  const _TarjetaActaDetalle({required this.acta});

  @override
  Widget build(BuildContext context) {
    final tieneGps = acta.gpsLat != null && acta.gpsLng != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgeEstado(acta: acta),
              const SizedBox(width: 8),
              Text(
                acta.dignidad == Dignidad.alcalde
                    ? 'Acta de Alcalde'
                    : 'Acta de Prefecto',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                'Mesa ${acta.mesaId}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          if (tieneGps) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${acta.gpsLat!.toStringAsFixed(6)}, ${acta.gpsLng!.toStringAsFixed(6)}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Registrada: ${_formatFecha(acta.createdAt)}',
            style:
                const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _BadgeEstado extends StatelessWidget {
  final Acta acta;
  const _BadgeEstado({required this.acta});

  @override
  Widget build(BuildContext context) {
    return switch (acta.estado) {
      EstadoActa.ingresada => _pill(
          'Ingresada', Colors.blue.shade700, Colors.blue.shade50),
      EstadoActa.revisada => _pill(
          'Revisada', Colors.green.shade700, Colors.green.shade50),
      EstadoActa.conNovedad => _pill(
          'Con novedad', Colors.red.shade700, Colors.red.shade50),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — DASHBOARD DE VOTOS
// ═════════════════════════════════════════════════════════════════════════════
class _TabDashboard extends ConsumerWidget {
  final String filtro;
  final ValueChanged<String> onFiltroChanged;

  const _TabDashboard({
    required this.filtro,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votosAsync = ref.watch(dashboardVotosProvider);

    return RefreshIndicator(
      color: const Color(0xFF1A237E),
      onRefresh: () async => ref.invalidate(dashboardVotosProvider),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Selector de dignidad
          _SelectorDignidad(
              valor: filtro, onChanged: onFiltroChanged),
          const SizedBox(height: 12),

          votosAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.red))),
            data: (votos) {
              final filtrados = filtro == 'Todos'
                  ? votos
                  : votos
                      .where((v) => v.dignidad == filtro)
                      .toList();

              if (filtrados.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text('Sin votos registrados aún.',
                        style: TextStyle(color: Color(0xFF9E9E9E))),
                  ),
                );
              }

              final maxVotos = filtrados.isEmpty
                  ? 1
                  : filtrados.first.totalVotos;

              return Column(
                children: filtrados
                    .asMap()
                    .entries
                    .map((e) => _BarraCandidato(
                          posicion: e.key + 1,
                          datos: e.value,
                          maxVotos: maxVotos,
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SelectorDignidad extends StatelessWidget {
  final String valor;
  final ValueChanged<String> onChanged;
  const _SelectorDignidad(
      {required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: ['Todos', 'Alcalde', 'Prefecto'].map((d) {
          final sel = valor == d;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color:
                      sel ? const Color(0xFF1A237E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF757575),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BarraCandidato extends StatelessWidget {
  final int posicion;
  final VotosCandidato datos;
  final int maxVotos;

  const _BarraCandidato({
    required this.posicion,
    required this.datos,
    required this.maxVotos,
  });

  @override
  Widget build(BuildContext context) {
    final porcentaje =
        maxVotos == 0 ? 0.0 : datos.totalVotos / maxVotos;
    final esPrimero = posicion == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esPrimero
              ? const Color(0xFF3949AB).withOpacity(0.4)
              : const Color(0xFFE0E0E0),
          width: esPrimero ? 1.5 : 0.5,
        ),
        boxShadow: esPrimero
            ? [
                BoxShadow(
                    color: const Color(0xFF1A237E).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ]
            : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NumeroPosicion(pos: posicion),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(datos.nombre,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121))),
                    Text(
                      '${datos.organizacion} · ${datos.dignidad}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ),
              Text(
                '${datos.totalVotos}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: esPrimero
                      ? const Color(0xFF1A237E)
                      : const Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8EAF6),
              color: esPrimero
                  ? const Color(0xFF3949AB)
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumeroPosicion extends StatelessWidget {
  final int pos;
  const _NumeroPosicion({required this.pos});

  @override
  Widget build(BuildContext context) {
    final colors = {
      1: [const Color(0xFFFFD700), const Color(0xFF8B6914)],
      2: [const Color(0xFFE8E8E8), const Color(0xFF616161)],
      3: [const Color(0xFFCD7F32), const Color(0xFF5D4037)],
    };
    final c = colors[pos] ??
        [const Color(0xFFF5F5F5), const Color(0xFF9E9E9E)];
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          color: c[0], shape: BoxShape.circle),
      child: Center(
        child: Text('$pos',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c[1])),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — COORDINADORES DE RECINTO
// ═════════════════════════════════════════════════════════════════════════════
class _TabCoordinadores extends ConsumerWidget {
  const _TabCoordinadores();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordsAsync = ref.watch(coordinadoresRecintoProvider);

    return RefreshIndicator(
      color: const Color(0xFF1A237E),
      onRefresh: () async =>
          ref.invalidate(coordinadoresRecintoProvider),
      child: coordsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (coords) {
          if (coords.isEmpty) {
            return const _EmptyState(
              icono: Icons.people_outline,
              mensaje: 'Sin coordinadores registrados',
              sub: 'Crea coordinadores desde el botón superior.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: coords.length,
            itemBuilder: (_, i) {
              final c = coords[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE0E0E0), width: 0.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE8EAF6),
                      child: Text(
                        c.nombres.isNotEmpty
                            ? c.nombres[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.nombres} ${c.apellidos}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(c.cedula,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    if (c.recintoId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('Recinto ${c.recintoId}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Widgets auxiliares
// ═════════════════════════════════════════════════════════════════════════════
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(mensaje,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(sub,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
            if (boton != null && onTap != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.add),
                label: Text(boton!),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool digitsOnly;
  final int? maxLength;

  const _Campo({
    required this.ctrl,
    required this.label,
    this.digitsOnly = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType:
          digitsOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null)
          LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}