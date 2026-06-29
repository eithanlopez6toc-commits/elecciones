// lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/recinto.dart';
import '../controller/login_controller.dart';
import 'coordinador_provincial_providers.dart';

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

class CedulaValidator {
  static bool isValid(String cedula) {
    final sanitized = cedula.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(sanitized)) return false;
    final digits = sanitized.split('').map(int.parse).toList();
    final province = int.parse(sanitized.substring(0, 2));
    if (province < 1 || province > 24) return false;
    final lastDigit = digits[9];
    int sum = 0;
    for (var i = 0; i < 9; i++) {
      final value = digits[i] * (i % 2 == 0 ? 2 : 1);
      sum += value > 9 ? value - 9 : value;
    }
    return ((10 - (sum % 10)) % 10) == lastDigit;
  }

  static String? validate(String? cedula) {
    final s = cedula?.trim();
    if (s == null || s.isEmpty) return 'La cédula es obligatoria';
    if (s.length != 10) return 'Debe tener 10 dígitos';
    if (!isValid(s)) return 'Cédula ecuatoriana no válida';
    return null;
  }
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
                    color: _Tema.onSurface))),
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

void _mostrarErrorDialog(BuildContext context, String mensaje) {
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
        const Expanded(
            child: Text('Ocurrió un error',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _Tema.onSurface))),
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

// ═══════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═══════════════════════════════════════════════════════════════
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
  String _dignidadFiltro = 'Todos';
  String? _recintoFiltro;

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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Portal Electoral Seguro',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _Tema.primary)),
              if (usuario != null)
                Text('Coordinador: ${usuario.nombres} ${usuario.apellidos}',
                    style: const TextStyle(
                        fontSize: 11, color: _Tema.onSurfaceVariant)),
            ]),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                size: 20, color: _Tema.onSurfaceVariant),
            onPressed: () async {
              // logout() ya no espera la red (ver fix en login_controller.dart)
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
                  icon: Icon(Icons.location_city_outlined, size: 20),
                  text: 'Inicio'),
              Tab(
                  icon: Icon(Icons.bar_chart_outlined, size: 20),
                  text: 'Actas'),
              Tab(
                  icon: Icon(Icons.people_outline, size: 20),
                  text: 'Coordinadores'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TabRecintos(
                onCrear: () => _dialogCrearRecinto(context),
                onCrearCoordinador: () => _dialogCrearCoordinador(context),
              ),
              _TabDashboard(
                filtroDigidad: _dignidadFiltro,
                filtroRecinto: _recintoFiltro,
                onFiltroDigidadChanged: (v) =>
                    setState(() => _dignidadFiltro = v),
                onFiltroRecintoChanged: (v) =>
                    setState(() => _recintoFiltro = v),
              ),
              const _TabCoordinadores(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Diálogo crear recinto ────────────────────────────────────
  void _dialogCrearRecinto(BuildContext context) {
    final ctrlNombre = TextEditingController();
    final ctrlCanton = TextEditingController();
    final ctrlParroquia = TextEditingController();
    final ctrlDireccion = TextEditingController();
    final ctrlNumJRV = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _Tema.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(24),
          children: [
            const Center(
                child: Icon(Icons.location_city_outlined,
                    size: 40, color: _Tema.primary)),
            const SizedBox(height: 12),
            const Text('Nuevo Recinto Electoral',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _Tema.onSurface)),
            const SizedBox(height: 24),
            Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_Tema.cardRadius),
                    border: Border.all(color: _Tema.outline)),
                child: Column(children: [
                  _CampoForm(
                      ctrl: ctrlNombre,
                      label: 'Nombre del recinto',
                      icono: Icons.business_outlined,
                      hint: 'Ej: Unidad Educativa del Milenio'),
                  const SizedBox(height: 16),
                  _CampoForm(
                      ctrl: ctrlCanton,
                      label: 'Cantón',
                      icono: Icons.map_outlined,
                      hint: 'Ej: Quito'),
                  const SizedBox(height: 16),
                  _CampoForm(
                      ctrl: ctrlParroquia,
                      label: 'Parroquia',
                      icono: Icons.gite_outlined,
                      hint: 'Ej: Belisario Quevedo'),
                  const SizedBox(height: 16),
                  _CampoForm(
                      ctrl: ctrlNumJRV,
                      label: 'Número de JRV / mesas',
                      icono: Icons.pin_outlined,
                      hint: 'Ej: 42',
                      digitsOnly: true),
                  const SizedBox(height: 16),
                  _CampoForm(
                      ctrl: ctrlDireccion,
                      label: 'Dirección (opcional)',
                      icono: Icons.place_outlined,
                      hint: 'Ej: Av. Amazonas N32',
                      required: false),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: _Tema.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await ref.read(crearRecintoProvider)(
                    ctrlCanton.text.trim(),
                    ctrlParroquia.text.trim(),
                    ctrlNombre.text.trim(),
                    ctrlDireccion.text.trim().isEmpty
                        ? null
                        : ctrlDireccion.text.trim(),
                    int.parse(ctrlNumJRV.text.trim()),
                  );
                  ref.invalidate(todosLosRecintosProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    _mostrarExitoDialog(context,
                        'Recinto creado correctamente y mesas generadas.');
                  }
                } catch (e) {
                  if (ctx.mounted) _mostrarErrorDialog(ctx, 'Error: $e');
                }
              },
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Guardar y Registrar',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: _Tema.onSurfaceVariant,
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: _Tema.outline),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Diálogo crear coordinador ────────────────────────────────
  void _dialogCrearCoordinador(BuildContext context) {
    final ctrlCedula = TextEditingController();
    final ctrlNombre = TextEditingController();
    final ctrlApellido = TextEditingController();
    final ctrlTelefono = TextEditingController();
    final ctrlCorreo = TextEditingController();
    int? recintoIdSeleccionado;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _Tema.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final recintosAsync = ref.watch(todosLosRecintosProvider);
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, sc) => ListView(
              controller: sc,
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                    child: Icon(Icons.person_add_outlined,
                        size: 40, color: _Tema.primary)),
                const SizedBox(height: 12),
                const Text('Nuevo Coordinador de Recinto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _Tema.onSurface)),
                const SizedBox(height: 8),
                const Text(
                    'Complete los datos para registrar al nuevo coordinador.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
                const SizedBox(height: 24),
                Form(
                  key: formKey,
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
                              hint: '0000000000',
                              digitsOnly: true,
                              maxLength: 10,
                              validator: CedulaValidator.validate),
                          const SizedBox(height: 16),
                          _CampoForm(
                              ctrl: ctrlNombre,
                              label: 'Nombres Completos',
                              icono: Icons.person_outline,
                              hint: 'Ej: Juan Antonio',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Obligatorio'
                                  : null),
                          const SizedBox(height: 16),
                          _CampoForm(
                              ctrl: ctrlApellido,
                              label: 'Apellidos Completos',
                              icono: Icons.person_outline,
                              hint: 'Ej: Pérez García',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Obligatorio'
                                  : null),
                          const SizedBox(height: 16),
                          _CampoForm(
                              ctrl: ctrlTelefono,
                              label: 'Teléfono',
                              icono: Icons.phone_outlined,
                              hint: '0999999999',
                              digitsOnly: true,
                              maxLength: 10),
                          const SizedBox(height: 16),
                          _CampoForm(
                              ctrl: ctrlCorreo,
                              label: 'Correo Electrónico',
                              icono: Icons.mail_outline,
                              hint: 'usuario@correo.com',
                              keyboard: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          const Row(children: [
                            Icon(Icons.business_outlined,
                                size: 16, color: _Tema.onSurfaceVariant),
                            SizedBox(width: 6),
                            Text('Asignar Recinto',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _Tema.onSurfaceVariant)),
                          ]),
                          const SizedBox(height: 6),
                          recintosAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error: $e'),
                            data: (recintos) {
                              final recintosAsync2 =
                                  ref.watch(coordinadoresRecintoProvider);
                              return recintosAsync2.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, _) => Text('Error: $e'),
                                data: (coordinadores) {
                                  final recintosOcupados = coordinadores
                                      .where((c) =>
                                          !c.debeCambiarPassword &&
                                          c.recintoId != null)
                                      .map((c) => c.recintoId!)
                                      .toSet();
                                  final recintosDisponibles = recintos
                                      .where((r) =>
                                          !recintosOcupados.contains(r.id))
                                      .toList();
                                  return DropdownButtonFormField<int>(
                                    value: recintoIdSeleccionado,
                                    hint: const Text('Seleccione un recinto...',
                                        style: TextStyle(fontSize: 13)),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: _Tema.outline)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: _Tema.outline)),
                                    ),
                                    items: recintosDisponibles
                                        .map((r) => DropdownMenuItem(
                                            value: r.id,
                                            child: Text(r.nombre,
                                                style: const TextStyle(
                                                    fontSize: 13))))
                                        .toList(),
                                    onChanged: (v) =>
                                        setS(() => recintoIdSeleccionado = v),
                                    validator: (v) => v == null
                                        ? 'Por favor asigne un recinto'
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
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
                                      'Se enviará una invitación al correo proporcionado con las credenciales de acceso.',
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
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: _Tema.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      await ref.read(crearCoordinadorRecintoProvider)(
                        ctrlCedula.text.trim(),
                        ctrlNombre.text.trim(),
                        ctrlApellido.text.trim(),
                        ctrlTelefono.text.trim(),
                        ctrlCorreo.text.trim(),
                        recintoIdSeleccionado!,
                      );
                      ref.invalidate(coordinadoresRecintoProvider);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        _mostrarExitoDialog(
                          context,
                          'Coordinador creado exitosamente. Se envió la invitación al correo registrado.',
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) _mostrarErrorDialog(ctx, 'Error: $e');
                    }
                  },
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_ind_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Guardar y Asignar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: _Tema.onSurfaceVariant,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: _Tema.outline),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB RECINTOS
// ═══════════════════════════════════════════════════════════════
class _TabRecintos extends ConsumerWidget {
  final VoidCallback onCrear;
  final VoidCallback onCrearCoordinador;
  const _TabRecintos({required this.onCrear, required this.onCrearCoordinador});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recintosAsync = ref.watch(todosLosRecintosProvider);
    final actasGlobalAsync = ref.watch(actasGlobalCountProvider);

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async {
        ref.invalidate(todosLosRecintosProvider);
        ref.invalidate(actasGlobalCountProvider);
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: onCrearCoordinador,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                  label: const Text('+ Coordinador',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: _Tema.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: onCrear,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nuevo Recinto',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          recintosAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (recintos) {
              final totalJRV =
                  recintos.fold<int>(0, (acc, r) => acc + r.numMesas);
              final totalActasPosibles = totalJRV * 2;

              return actasGlobalAsync.when(
                loading: () => Column(
                  children: [
                    _CardKPI(
                        label: 'TOTAL RECINTOS',
                        value: '${recintos.length}',
                        icon: Icons.business_outlined),
                    const SizedBox(height: 10),
                    _CardKPI(
                        label: 'TOTAL JRV (MESAS)',
                        value: '$totalJRV',
                        icon: Icons.how_to_vote_outlined),
                    const SizedBox(height: 10),
                    const _CardKPI(
                        label: 'PROGRESO GLOBAL DE ACTAS',
                        value: '...',
                        icon: Icons.analytics_outlined),
                  ],
                ),
                error: (_, __) => Column(
                  children: [
                    _CardKPI(
                        label: 'TOTAL RECINTOS',
                        value: '${recintos.length}',
                        icon: Icons.business_outlined),
                    const SizedBox(height: 10),
                    _CardKPI(
                        label: 'TOTAL JRV (MESAS)',
                        value: '$totalJRV',
                        icon: Icons.how_to_vote_outlined),
                    const SizedBox(height: 10),
                    const _CardKPI(
                        label: 'PROGRESO GLOBAL DE ACTAS',
                        value: 'Error',
                        icon: Icons.analytics_outlined),
                  ],
                ),
                data: (totalActas) {
                  final progreso = totalActasPosibles == 0
                      ? 0.0
                      : (totalActas / totalActasPosibles).clamp(0.0, 1.0);
                  return Column(
                    children: [
                      _CardKPI(
                          label: 'TOTAL RECINTOS',
                          value: '${recintos.length}',
                          icon: Icons.business_outlined),
                      const SizedBox(height: 10),
                      _CardKPI(
                          label: 'TOTAL JRV (MESAS)',
                          value: '$totalJRV',
                          icon: Icons.how_to_vote_outlined),
                      const SizedBox(height: 10),
                      _CardKPI(
                        label: 'PROGRESO GLOBAL DE ACTAS',
                        value: '${(progreso * 100).toStringAsFixed(1)}%',
                        icon: Icons.analytics_outlined,
                        progress: progreso,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Recintos Registrados',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurfaceVariant)),
          const SizedBox(height: 8),
          recintosAsync.when(
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: _Tema.errorColor))),
            data: (recintos) {
              if (recintos.isEmpty) {
                return _EmptyState(
                    icono: Icons.location_city_outlined,
                    mensaje: 'Sin recintos',
                    sub: 'Crea el primero usando el botón superior.',
                    onTap: onCrear);
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recintos.length,
                itemBuilder: (_, i) =>
                    _TarjetaRecintoModerno(recinto: recintos[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TARJETA RECINTO MODERNO
// ═══════════════════════════════════════════════════════════════
class _TarjetaRecintoModerno extends ConsumerWidget {
  final Recinto recinto;
  const _TarjetaRecintoModerno({required this.recinto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenPorRecintoProvider(recinto));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: InkWell(
        borderRadius: BorderRadius.circular(_Tema.cardRadius),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => _DetalleRecintoScreen(recinto: recinto))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(recinto.nombre,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _Tema.onSurface)),
                  ),
                  resumenAsync.when(
                    loading: () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const SizedBox(),
                    data: (r) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.porcentaje == 1.0
                            ? _Tema.successContainer
                            : _Tema.brandAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r.porcentaje == 1.0 ? 'COMPLETO' : 'PENDIENTE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: r.porcentaje == 1.0
                                ? _Tema.success
                                : _Tema.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _IconInfoRow(
                  icon: Icons.location_on_outlined,
                  text: '${recinto.canton}, ${recinto.parroquia}'),
              const SizedBox(height: 4),
              _IconInfoRow(
                  icon: Icons.how_to_vote_outlined,
                  text: '${recinto.numMesas} JRV (Mesas)'),
              const SizedBox(height: 12),
              resumenAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (r) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Avance de Actas',
                            style: TextStyle(
                                fontSize: 11, color: _Tema.onSurfaceVariant)),
                        Text('${(r.porcentaje * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _Tema.primary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: r.porcentaje,
                          minHeight: 6,
                          backgroundColor: _Tema.background,
                          color: _Tema.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.arrow_forward,
                      size: 16, color: _Tema.greyLight)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _Tema.greyLight),
        const SizedBox(width: 6),
        Text(text,
            style:
                const TextStyle(fontSize: 12, color: _Tema.onSurfaceVariant)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB DASHBOARD
// ═══════════════════════════════════════════════════════════════
class _TabDashboard extends ConsumerWidget {
  final String filtroDigidad;
  final String? filtroRecinto;
  final ValueChanged<String> onFiltroDigidadChanged;
  final ValueChanged<String?> onFiltroRecintoChanged;

  const _TabDashboard({
    required this.filtroDigidad,
    required this.filtroRecinto,
    required this.onFiltroDigidadChanged,
    required this.onFiltroRecintoChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votosAsync = ref.watch(dashboardVotosProvider);
    final recintosAsync = ref.watch(todosLosRecintosProvider);

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async => ref.invalidate(dashboardVotosProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: recintosAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (recintos) => _SelectorRecinto(
                      recintos: recintos,
                      seleccionado: filtroRecinto,
                      onChanged: onFiltroRecintoChanged),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SelectorDignidad(
              valor: filtroDigidad, onChanged: onFiltroDigidadChanged),
          const SizedBox(height: 16),
          votosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: _Tema.errorColor))),
            data: (votos) {
              var filtrados = filtroRecinto != null
                  ? votos
                      .where((v) => v.recintoNombre == filtroRecinto)
                      .toList()
                  : votos;
              filtrados = filtroDigidad == 'Todos'
                  ? filtrados
                  : filtrados
                      .where((v) => v.dignidad == filtroDigidad)
                      .toList();

              if (filtrados.isEmpty) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('Sin actas validadas para este filtro.',
                            style: TextStyle(color: _Tema.greyLight))));
              }

              final totalVotos =
                  filtrados.fold<int>(0, (acc, v) => acc + v.totalVotos);
              final maxVotos =
                  filtrados.isEmpty ? 1 : filtrados.first.totalVotos;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardKPI(
                      label: 'TOTAL VOTOS ESCRUTADOS',
                      value: '$totalVotos',
                      icon: Icons.trending_up_outlined),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_Tema.cardRadius),
                        border: Border.all(color: _Tema.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Resultados Consolidados',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _Tema.onSurface)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: _Tema.primary,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(filtroDigidad,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const Divider(height: 24),
                        ...filtrados.asMap().entries.map((e) =>
                            _FilaCandidatoModerno(
                                posicion: e.key + 1,
                                datos: e.value,
                                maxVotos: maxVotos)),
                      ],
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
}

class _FilaCandidatoModerno extends StatelessWidget {
  final int posicion;
  final VotosCandidato datos;
  final int maxVotos;

  const _FilaCandidatoModerno(
      {required this.posicion, required this.datos, required this.maxVotos});

  @override
  Widget build(BuildContext context) {
    final porcentaje = maxVotos == 0 ? 0.0 : datos.totalVotos / maxVotos;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _Tema.brandAccent,
                child: Text('$posicion',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: _Tema.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(datos.nombre,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _Tema.onSurface)),
                    Text(datos.organizacion,
                        style: const TextStyle(
                            fontSize: 11, color: _Tema.greyLight)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${datos.totalVotos} Votos',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _Tema.primary)),
                  Text('${(porcentaje * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 11, color: _Tema.onSurfaceVariant)),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: porcentaje,
                minHeight: 6,
                backgroundColor: _Tema.background,
                color: posicion == 1 ? _Tema.primary : _Tema.greyLight),
          )
        ],
      ),
    );
  }
}

class _SelectorRecinto extends StatelessWidget {
  final List<Recinto> recintos;
  final String? seleccionado;
  final ValueChanged<String?> onChanged;

  const _SelectorRecinto(
      {required this.recintos,
      required this.seleccionado,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Tema.outline)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: seleccionado,
          isExpanded: true,
          icon: const Icon(Icons.filter_list_outlined, color: _Tema.primary),
          items: [
            const DropdownMenuItem<String?>(
                value: null,
                child:
                    Text('Todos los recintos', style: TextStyle(fontSize: 13))),
            ...recintos.map((r) => DropdownMenuItem<String?>(
                value: r.nombre,
                child: Text(r.nombre, style: const TextStyle(fontSize: 13)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SelectorDignidad extends StatelessWidget {
  final String valor;
  final ValueChanged<String> onChanged;
  const _SelectorDignidad({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _Tema.outline)),
      child: Row(
        children: ['Todos', 'Alcalde', 'Prefecto'].map((d) {
          final isSel = valor == d;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(d),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color: isSel ? _Tema.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : _Tema.onSurfaceVariant)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB COORDINADORES
// ═══════════════════════════════════════════════════════════════
class _TabCoordinadores extends ConsumerWidget {
  const _TabCoordinadores();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordsAsync = ref.watch(coordinadoresRecintoProvider);

    return RefreshIndicator(
      color: _Tema.primary,
      onRefresh: () async => ref.invalidate(coordinadoresRecintoProvider),
      child: coordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: _Tema.errorColor))),
        data: (coords) {
          if (coords.isEmpty) {
            return const _EmptyState(
                icono: Icons.people_outline,
                mensaje: 'Sin coordinadores registrados',
                sub: 'Agregue nuevos delegados institucionales.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coords.length,
            itemBuilder: (_, i) {
              final c = coords[i];
              final aceptado = !c.debeCambiarPassword;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_Tema.cardRadius),
                    border: Border.all(
                        color: aceptado
                            ? _Tema.outline
                            : _Tema.warningColor.withOpacity(0.4))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: aceptado
                              ? _Tema.successContainer
                              : _Tema.warningContainer,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        aceptado
                            ? Icons.verified_user_outlined
                            : Icons.person_outline,
                        size: 20,
                        color: aceptado ? _Tema.success : _Tema.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c.nombres} ${c.apellidos}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _Tema.onSurface)),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: _Tema.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                    c.recintoId != null
                                        ? 'Recinto #${c.recintoId}'
                                        : 'Sin recinto asignado',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: _Tema.onSurfaceVariant),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: aceptado
                                      ? _Tema.successContainer
                                      : _Tema.warningContainer,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                aceptado ? 'Solicitud aceptada' : 'Pendiente',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: aceptado
                                        ? _Tema.success
                                        : _Tema.warningColor),
                              ),
                            ),
                          ]),
                    ),
                    if (!aceptado)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: _Tema.errorColor, size: 20),
                        tooltip: 'Eliminar coordinador pendiente',
                        onPressed: () => _confirmarEliminar(
                            context, ref, c.id, '${c.nombres} ${c.apellidos}'),
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

  void _confirmarEliminar(
      BuildContext context, WidgetRef ref, String userId, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_Tema.cardRadius)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: _Tema.warningColor),
          SizedBox(width: 8),
          Text('Eliminar coordinador',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        content: Text(
          '¿Deseas eliminar a $nombre? Su solicitud aún está pendiente.',
          style: const TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: _Tema.errorColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(eliminarCoordinadorProvider)(userId);
                ref.invalidate(coordinadoresRecintoProvider);
                if (context.mounted) {
                  _mostrarExitoDialog(
                      context, 'Coordinador eliminado correctamente.');
                }
              } catch (e) {
                if (context.mounted) {
                  _mostrarErrorDialog(context, 'Error al eliminar: $e');
                }
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DETALLE DE RECINTO
// ═══════════════════════════════════════════════════════════════
class _DetalleRecintoScreen extends ConsumerWidget {
  final Recinto recinto;
  const _DetalleRecintoScreen({required this.recinto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasDeRecintoProvider(recinto.id));

    return Scaffold(
      backgroundColor: _Tema.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _Tema.primary,
        elevation: 0,
        title: Text(recinto.nombre,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: actasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: _Tema.errorColor))),
        data: (actas) {
          if (actas.isEmpty) {
            return const Center(
                child: Text('Sin actas ingresadas en este recinto.',
                    style: TextStyle(color: _Tema.greyLight)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
          border: Border.all(color: _Tema.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BadgeEstado(acta: acta),
              Text('Mesa ${acta.mesaId}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _Tema.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              acta.dignidad == Dignidad.alcalde
                  ? 'Dignidad: Alcalde'
                  : 'Dignidad: Prefecto',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _Tema.onSurface)),
          const SizedBox(height: 8),
          if (tieneGps)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _Tema.successContainer,
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined,
                      size: 14, color: _Tema.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        'Ubicación validada (${acta.gpsLat!.toStringAsFixed(4)}, ${acta.gpsLng!.toStringAsFixed(4)})',
                        style: const TextStyle(
                            fontSize: 11, color: _Tema.success)),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _Tema.warningContainer,
                  borderRadius: BorderRadius.circular(6)),
              child: const Row(
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 14, color: _Tema.warningColor),
                  SizedBox(width: 6),
                  Text('Coordenadas GPS no capturadas',
                      style:
                          TextStyle(fontSize: 11, color: _Tema.warningColor)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final Acta acta;
  const _BadgeEstado({required this.acta});

  @override
  Widget build(BuildContext context) {
    return switch (acta.estado) {
      EstadoActa.ingresada =>
        _pill('Ingresada', _Tema.primary, _Tema.brandAccent),
      EstadoActa.revisada =>
        _pill('Escrutado 100%', _Tema.success, _Tema.successContainer),
      EstadoActa.conNovedad =>
        _pill('Con Novedad', _Tema.errorColor, _Tema.errorContainer),
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

// ═══════════════════════════════════════════════════════════════
// WIDGETS REUTILIZABLES
// ═══════════════════════════════════════════════════════════════
class _CardKPI extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double? progress;
  const _CardKPI({
    required this.label,
    required this.value,
    required this.icon,
    this.progress,
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
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _Tema.greyLight,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _Tema.onSurface)),
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
          ]
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String sub;
  final VoidCallback? onTap;

  const _EmptyState({
    required this.icono,
    required this.mensaje,
    required this.sub,
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
            Icon(icono, size: 48, color: _Tema.greyLight),
            const SizedBox(height: 12),
            Text(mensaje,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _Tema.onSurface)),
            const SizedBox(height: 4),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: _Tema.greyLight)),
            if (onTap != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                    backgroundColor: _Tema.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('Crear recinto'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _CampoForm extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icono;
  final String hint;
  final bool digitsOnly;
  final bool required;
  final int? maxLength;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;

  const _CampoForm({
    required this.ctrl,
    required this.label,
    required this.icono,
    required this.hint,
    this.digitsOnly = false,
    this.required = true,
    this.maxLength,
    this.keyboard,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icono, size: 14, color: _Tema.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _Tema.onSurfaceVariant)),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*',
              style: TextStyle(
                  color: _Tema.errorColor, fontWeight: FontWeight.bold)),
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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _Tema.greyLight),
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _Tema.outline)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _Tema.outline)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _Tema.primary)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _Tema.errorColor)),
        ),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? 'Este campo es obligatorio'
                    : null
                : null),
      ),
    ]);
  }
}
