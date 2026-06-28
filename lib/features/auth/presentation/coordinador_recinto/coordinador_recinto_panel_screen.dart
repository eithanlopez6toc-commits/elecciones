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
// DESIGN SYSTEM — Portal Electoral Seguro (unificado con Provincial)
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
                Icon(Icons.location_off_outlined, size: 48, color: _Tema.greyLight),
                SizedBox(height: 12),
                Text('Sin recinto asignado',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
                SizedBox(height: 4),
                Text('Contacta al coordinador provincial para recibir asignación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
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
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: _Tema.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Portal Electoral Seguro',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _Tema.primary)),
                  Text('Coordinador: ${usuario.nombres} ${usuario.apellidos}',
                      style: const TextStyle(fontSize: 11, color: _Tema.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20, color: _Tema.onSurfaceVariant),
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: _Tema.primary,
              indicatorWeight: 3,
              labelColor: _Tema.primary,
              unselectedLabelColor: _Tema.onSurfaceVariant,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.grid_view_outlined, size: 20), text: 'Mesas'),
                Tab(icon: Icon(Icons.badge_outlined, size: 20), text: 'Veedores'),
                Tab(icon: Icon(Icons.swap_horiz_outlined, size: 20), text: 'Reasignar'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _TabMesas(
                  recintoId: recintoId,
                  usuario: usuario,
                  onIrAVeedores: () => _tabCtrl.animateTo(1),
                ),
                _TabVeedores(
                  recintoId: recintoId,
                  usuario: usuario,
                  onRegistroExitoso: () => _tabCtrl.animateTo(0),
                ),
                _TabReasignar(recintoId: recintoId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — MESAS
// ═════════════════════════════════════════════════════════════════════════════
class _TabMesas extends ConsumerWidget {
  final int recintoId;
  final Usuario usuario;
  final VoidCallback onIrAVeedores;

  const _TabMesas({required this.recintoId, required this.usuario, required this.onIrAVeedores});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenRecintoProvider(recintoId));
    final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async {
        ref.invalidate(resumenRecintoProvider(recintoId));
        ref.invalidate(mesasPorRecintoProvider(recintoId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: _Tema.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: onIrAVeedores,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                  label: const Text('+ Veedor', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: _Tema.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _dialogCrearMesa(context, ref, recintoId),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nueva Mesa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          resumenAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (e, _) => const SizedBox(),
            data: (r) => Column(
              children: [
                _CardKPI(label: 'TOTAL MESAS', value: '${r.totalMesas}', icon: Icons.grid_on_outlined),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _CardKPI(label: 'ACTAS ALCALDE', value: '${r.mesasConActaAlcalde}', icon: Icons.how_to_vote_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _CardKPI(label: 'ACTAS PREFECTO', value: '${r.mesasConActaPrefecto}', icon: Icons.how_to_vote_outlined)),
                  ],
                ),
                const SizedBox(height: 10),
                _CardKPI(
                  label: 'PENDIENTES',
                  value: '${r.actasPendientes}',
                  icon: Icons.pending_actions_outlined,
                  valueColor: r.actasPendientes > 0 ? _Tema.errorColor : _Tema.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Listado de Mesas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Tema.onSurfaceVariant)),
          const SizedBox(height: 8),
          mesasAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: _Tema.errorColor))),
            data: (mesas) {
              if (mesas.isEmpty) {
                return _EmptyState(
                  icono: Icons.table_rows_outlined,
                  mensaje: 'Sin mesas registradas',
                  sub: 'Agrega la primera mesa usando el botón superior.',
                  boton: 'Agregar mesa',
                  onTap: () => _dialogCrearMesa(context, ref, recintoId),
                );
              }
              return Column(children: mesas.map((m) => _TarjetaMesa(mesa: m, usuario: usuario)).toList());
            },
          ),
        ],
      ),
    );
  }

  void _dialogCrearMesa(BuildContext context, WidgetRef ref, int recintoId) {
    final ctrlNumero = TextEditingController();
    GeneroMesa generoSeleccionado = GeneroMesa.unica;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _Tema.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, sc) => ListView(
            controller: sc,
            padding: const EdgeInsets.all(24),
            children: [
              const Center(child: Icon(Icons.table_rows_outlined, size: 40, color: _Tema.primary)),
              const SizedBox(height: 12),
              const Text('Nueva Mesa / JRV',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_Tema.cardRadius),
                    border: Border.all(color: _Tema.outline)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CampoLabel(icono: Icons.pin_outlined, texto: 'Número de mesa'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: ctrlNumero,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDeco('Ej: 42'),
                    ),
                    const SizedBox(height: 16),
                    _CampoLabel(icono: Icons.people_outline, texto: 'Género de mesa'),
                    ...GeneroMesa.values.map((g) => RadioListTile<GeneroMesa>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(g.dbValue, style: const TextStyle(fontSize: 13)),
                          value: g,
                          groupValue: generoSeleccionado,
                          activeColor: _Tema.primary,
                          onChanged: (v) => setS(() => generoSeleccionado = v!),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _Tema.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  final numero = int.tryParse(ctrlNumero.text.trim());
                  if (numero == null) return;
                  try {
                    await ref.read(crearMesaProvider)(recintoId, numero, generoSeleccionado);
                    ref.invalidate(mesasPorRecintoProvider(recintoId));
                    ref.invalidate(resumenRecintoProvider(recintoId));
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: _Tema.errorColor));
                    }
                  }
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.save_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Guardar Mesa', style: TextStyle(fontWeight: FontWeight.bold))
                ]),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: _Tema.onSurfaceVariant,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: _Tema.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TARJETA DE MESA — colapsada con badge, expandible al tocar
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
          border: Border.all(color: _expandida ? _Tema.primary.withOpacity(0.3) : _Tema.outline)),
      child: Column(
        children: [
          // Cabecera siempre visible — toca para expandir
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _expandida ? Colors.white : _Tema.brandAccent,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.how_to_vote_outlined, size: 18, color: _Tema.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mesa ${widget.mesa.numeroMesa.toString().padLeft(3, '0')}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _Tema.onSurface),
                        ),
                        Text(widget.mesa.genero.dbValue,
                            style: const TextStyle(fontSize: 12, color: _Tema.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  // Badge resumen de estado
                  actasAsync.when(
                    loading: () => const SizedBox(
                        width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const SizedBox(),
                    data: (actas) {
                      final tieneAlcalde = actas.any((a) => a.dignidad == Dignidad.alcalde);
                      final tienePrefecto = actas.any((a) => a.dignidad == Dignidad.prefecto);
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
                    _expandida ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _Tema.greyLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Contenido expandido — filas de actas con botón
          if (_expandida)
            actasAsync.when(
              loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $e', style: const TextStyle(color: _Tema.errorColor))),
              data: (actas) {
                final actaAlcalde = actas.where((a) => a.dignidad == Dignidad.alcalde).firstOrNull;
                final actaPrefecto = actas.where((a) => a.dignidad == Dignidad.prefecto).firstOrNull;
                return Column(
                  children: [
                    Container(height: 1, color: _Tema.outline),
                    _FilaActa(
                      etiqueta: 'Acta de Alcalde',
                      acta: actaAlcalde,
                      onTap: () => _irAFormulario(context, ref, Dignidad.alcalde, actaAlcalde),
                    ),
                    Container(height: 1, color: _Tema.outline),
                    _FilaActa(
                      etiqueta: 'Acta de Prefecto',
                      acta: actaPrefecto,
                      onTap: () => _irAFormulario(context, ref, Dignidad.prefecto, actaPrefecto),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      );

  Future<void> _irAFormulario(
      BuildContext context, WidgetRef ref, Dignidad dignidad, Acta? actaExistente) async {
    // Espera a que carguen las orgs (provider corregido en veedor_providers.dart)
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
    ref.invalidate(actasDeMesaProvider(widget.mesa.id));
    ref.invalidate(resumenRecintoProvider(widget.mesa.recintoId));
  }
}

class _FilaActa extends StatelessWidget {
  final String etiqueta;
  final Acta? acta;
  final VoidCallback onTap;

  const _FilaActa({required this.etiqueta, required this.acta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            registrada ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: registrada ? _Tema.success : _Tema.greyLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _Tema.onSurface)),
                if (acta?.gpsLat != null)
                  const Text('GPS registrado',
                      style: TextStyle(fontSize: 11, color: _Tema.onSurfaceVariant)),
              ],
            ),
          ),
          _BadgeActa(acta: acta),
          const SizedBox(width: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: registrada ? _Tema.primary : _Tema.success,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onTap,
            icon: Icon(registrada ? Icons.edit_outlined : Icons.note_add_outlined, size: 14),
            label: Text(
              registrada ? 'Actualizar' : 'Ingresar',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeActa extends StatelessWidget {
  final Acta? acta;
  const _BadgeActa({required this.acta});

  @override
  Widget build(BuildContext context) {
    if (acta == null) return _pill('Pendiente', _Tema.warningColor, _Tema.warningContainer);
    return switch (acta!.estado) {
      EstadoActa.ingresada => _pill('Ingresada', _Tema.primary, _Tema.brandAccent),
      EstadoActa.revisada => _pill('Revisada', _Tema.success, _Tema.successContainer),
      EstadoActa.conNovedad => _pill('Novedad', _Tema.errorColor, _Tema.errorContainer),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — VEEDORES: lista + formulario inline
// ═════════════════════════════════════════════════════════════════════════════
class _TabVeedores extends ConsumerStatefulWidget {
  final int recintoId;
  final Usuario usuario;
  final VoidCallback onRegistroExitoso;

  const _TabVeedores({required this.recintoId, required this.usuario, required this.onRegistroExitoso});

  @override
  ConsumerState<_TabVeedores> createState() => _TabVeedoresState();
}

class _TabVeedoresState extends ConsumerState<_TabVeedores> {
  bool _mostrarFormulario = false;
  final ctrlCedula = TextEditingController();
  final ctrlNombre = TextEditingController();
  final ctrlApellido = TextEditingController();
  final ctrlTelefono = TextEditingController();
  final ctrlCorreo = TextEditingController();
  int? _mesaIdSeleccionada;
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
    setState(() {
      _mesaIdSeleccionada = null;
      _mostrarFormulario = false;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final veedoresAsync = ref.watch(veedoresDeRecintoProvider(widget.recintoId));
    final mesasAsync = ref.watch(mesasPorRecintoProvider(widget.recintoId));

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async => ref.invalidate(veedoresDeRecintoProvider(widget.recintoId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Botón superior ─────────────────────────────────────────────────
          _mostrarFormulario
              ? OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: _Tema.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: _limpiar,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Ver lista de veedores', style: TextStyle(fontSize: 12)),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: _Tema.primary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => setState(() => _mostrarFormulario = true),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Agregar Veedor',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
          const SizedBox(height: 16),

          if (_mostrarFormulario) ...[
            // ── FORMULARIO ─────────────────────────────────────────────────
            const Center(child: Icon(Icons.person_add_outlined, size: 40, color: _Tema.primary)),
            const SizedBox(height: 12),
            const Text('Registrar Nuevo Veedor',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
            const SizedBox(height: 8),
            const Text('Complete los datos para dar de alta al nuevo veedor electoral.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_Tema.cardRadius),
                    border: Border.all(color: _Tema.outline)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CampoForm(
                        ctrl: ctrlCedula,
                        label: 'Cédula de Identidad',
                        icono: Icons.badge_outlined,
                        hint: 'Ej: 0000000000 (10 dígitos)',
                        digitsOnly: true,
                        maxLength: 10,
                        validator: CedulaValidator.validate),
                    const SizedBox(height: 16),
                    _CampoForm(
                        ctrl: ctrlNombre,
                        label: 'Nombres Completos',
                        icono: Icons.person_outline,
                        hint: 'Ej: Juan Andrés',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null),
                    const SizedBox(height: 16),
                    _CampoForm(
                        ctrl: ctrlApellido,
                        label: 'Apellidos Completos',
                        icono: Icons.person_outline,
                        hint: 'Ej: Pérez García',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null),
                    const SizedBox(height: 16),
                    _CampoForm(
                        ctrl: ctrlTelefono,
                        label: 'Teléfono de Contacto',
                        icono: Icons.phone_outlined,
                        hint: 'Ej: 0999999999',
                        digitsOnly: true,
                        maxLength: 10,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatorio';
                          if (v.length < 9) return 'Teléfono inválido';
                          return null;
                        }),
                    const SizedBox(height: 16),
                    _CampoForm(
                        ctrl: ctrlCorreo,
                        label: 'Correo Electrónico',
                        icono: Icons.mail_outline,
                        hint: 'usuario@correo.com',
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim()))
                            return 'Correo inválido';
                          return null;
                        }),
                    const SizedBox(height: 16),
                    _CampoLabel(icono: Icons.grid_view_outlined, texto: 'Mesa a Asignar (JRV)'),
                    const SizedBox(height: 6),
                    mesasAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                      data: (mesas) => DropdownButtonFormField<int>(
                        value: _mesaIdSeleccionada,
                        hint: const Text('Seleccione una mesa disponible...', style: TextStyle(fontSize: 13)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _Tema.outline)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _Tema.outline)),
                        ),
                        items: mesas
                            .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text('Mesa ${m.numeroMesa} — ${m.genero.dbValue}',
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) => setState(() => _mesaIdSeleccionada = v),
                        validator: (v) => v == null ? 'Selecciona una mesa' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: _Tema.brandAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _Tema.primary.withOpacity(0.1))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline, size: 18, color: _Tema.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Se enviará una invitación de acceso seguro al correo proporcionado.',
                              style: TextStyle(fontSize: 11, color: _Tema.primary, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: _Tema.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Veedor registrado · Se envió correo de confirmación'),
                      backgroundColor: _Tema.success,
                    ));
                    widget.onRegistroExitoso();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: _Tema.errorColor));
                  }
                }
              },
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.assignment_ind_outlined, size: 18),
                SizedBox(width: 8),
                Text('Finalizar Registro', style: TextStyle(fontWeight: FontWeight.bold))
              ]),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: _Tema.onSurfaceVariant,
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: _Tema.outline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _limpiar,
              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            // ── LISTA DE VEEDORES ──────────────────────────────────────────
            const Text('Veedores Registrados',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Tema.onSurfaceVariant)),
            const SizedBox(height: 8),
            veedoresAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: _Tema.errorColor))),
              data: (veedores) {
                if (veedores.isEmpty) {
                  return _EmptyState(
                    icono: Icons.badge_outlined,
                    mensaje: 'Sin veedores registrados',
                    sub: 'Agrega el primero con el botón superior.',
                    boton: 'Agregar Veedor',
                    onTap: () => setState(() => _mostrarFormulario = true),
                  );
                }
                return Column(children: veedores.map((v) => _TarjetaVeedor(veedor: v)).toList());
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaVeedor extends StatelessWidget {
  final Usuario veedor;
  const _TarjetaVeedor({required this.veedor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _Tema.brandAccent,
            child: Text(
                veedor.nombres.isNotEmpty ? veedor.nombres[0].toUpperCase() : '?',
                style: const TextStyle(color: _Tema.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${veedor.nombres} ${veedor.apellidos}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
                const SizedBox(height: 2),
                Text('C.C: ${veedor.cedula}',
                    style: const TextStyle(fontSize: 11, color: _Tema.onSurfaceVariant)),
                if (veedor.correo.isNotEmpty)
                  Text(veedor.correo, style: const TextStyle(fontSize: 11, color: _Tema.greyLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _Tema.successContainer, borderRadius: BorderRadius.circular(4)),
            child: const Text('Activo',
                style: TextStyle(fontSize: 10, color: _Tema.success, fontWeight: FontWeight.bold)),
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Tema.onSurfaceVariant)),
          const SizedBox(height: 8),
          mesasAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: _Tema.errorColor))),
            data: (mesas) {
              if (mesas.isEmpty) {
                return const _EmptyState(
                  icono: Icons.swap_horiz_outlined,
                  mensaje: 'Sin mesas disponibles',
                  sub: 'Registra mesas primero en la pestaña Mesas.',
                );
              }
              return Column(children: mesas.map((m) => _TarjetaReasignacion(mesa: m)).toList());
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
        onTap: () => showDialog(context: context, builder: (ctx) => _DialogoReasignar(mesa: mesa)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _Tema.brandAccent, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.how_to_vote_outlined, size: 20, color: _Tema.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mesa ${mesa.numeroMesa.toString().padLeft(3, '0')}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
                    Text(mesa.genero.dbValue,
                        style: const TextStyle(fontSize: 12, color: _Tema.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _Tema.brandAccent, borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 14, color: _Tema.primary),
                    SizedBox(width: 4),
                    Text('Reasignar',
                        style: TextStyle(fontSize: 11, color: _Tema.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DIÁLOGO REASIGNAR
// ═════════════════════════════════════════════════════════════════════════════
class _DialogoReasignar extends ConsumerStatefulWidget {
  final MesaJrv mesa;
  const _DialogoReasignar({required this.mesa});

  @override
  ConsumerState<_DialogoReasignar> createState() => _DialogoReasignarState();
}

class _DialogoReasignarState extends ConsumerState<_DialogoReasignar> {
  String? _veedorSeleccionado;

  @override
  Widget build(BuildContext context) {
    final veedoresAsync = ref.watch(veedoresDeRecintoProvider(widget.mesa.recintoId));

    return AlertDialog(
      backgroundColor: _Tema.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_Tema.cardRadius)),
      title: Column(
        children: [
          const Icon(Icons.swap_horiz_outlined, size: 36, color: _Tema.primary),
          const SizedBox(height: 8),
          Text('Reasignar Veedor\nMesa ${widget.mesa.numeroMesa}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
        ],
      ),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_Tema.cardRadius),
            border: Border.all(color: _Tema.outline)),
        child: veedoresAsync.when(
          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
          data: (veedores) {
            if (veedores.isEmpty) {
              return const Text('No hay veedores disponibles en este recinto.',
                  style: TextStyle(fontSize: 14));
            }
            return DropdownButtonFormField<String>(
              value: _veedorSeleccionado,
              hint: const Text('Seleccionar veedor disponible', style: TextStyle(fontSize: 13)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _Tema.outline)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: veedores
                  .map((v) => DropdownMenuItem(
                        value: v.id,
                        child: Text('${v.nombres} ${v.apellidos}', style: const TextStyle(fontSize: 13)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: _Tema.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: _veedorSeleccionado == null
              ? null
              : () async {
                  try {
                    await ref.read(reasignarVeedorProvider)(_veedorSeleccionado!, widget.mesa.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Veedor reasignado exitosamente'),
                        backgroundColor: _Tema.success,
                      ));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: _Tema.errorColor));
                    }
                  }
                },
          child: const Text('Confirmar Reasignación', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS COMPARTIDOS
// ═════════════════════════════════════════════════════════════════════════════
class _CardKPI extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _CardKPI({required this.label, required this.value, required this.icon, this.valueColor});

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
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: _Tema.greyLight, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: valueColor ?? _Tema.onSurface)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String sub;
  final String? boton;
  final VoidCallback? onTap;

  const _EmptyState({required this.icono, required this.mensaje, required this.sub, this.boton, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icono, size: 48, color: _Tema.greyLight),
            const SizedBox(height: 12),
            Text(mensaje,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Tema.onSurface)),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: _Tema.greyLight)),
            if (boton != null && onTap != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _Tema.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: onTap,
                child: Text(boton!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CampoLabel extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _CampoLabel({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 14, color: _Tema.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(texto,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _Tema.onSurfaceVariant)),
      ],
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
          borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _Tema.outline)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _Tema.outline)),
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
  final bool required;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;

  const _CampoForm({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.icono,
    this.digitsOnly = false,
    this.maxLength,
    this.required = true,
    this.validator,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CampoLabel(icono: icono ?? Icons.edit_outlined, texto: label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard ?? (digitsOnly ? TextInputType.number : TextInputType.text),
          inputFormatters: [
            if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
          decoration: _inputDeco(hint),
          validator: validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null
                  : null),
        ),
      ],
    );
  }
}