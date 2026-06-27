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

class CoordinadorRecintoPanelScreen extends ConsumerWidget {
  const CoordinadorRecintoPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider);
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final recintoId = usuario.recintoId;
    if (recintoId == null) {
      return const Scaffold(
        body: Center(
            child: Text(
                'Sin recinto asignado. Contacta al coordinador provincial.')),
      );
    }

    final resumenAsync = ref.watch(resumenRecintoProvider(recintoId));
    final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));

    return Scaffold(
      backgroundColor: _Tema.background,
      appBar: AppBar(
        backgroundColor: _Tema.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coordinador de Recinto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('${usuario.nombres} ${usuario.apellidos}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, size: 20),
            tooltip: 'Crear veedor',
            onPressed: () =>
                _mostrarDialogoCrearVeedor(context, ref, recintoId),
          ),
          IconButton(
            icon: const Icon(Icons.add_road_outlined, size: 20),
            tooltip: 'Agregar mesa',
            onPressed: () => _mostrarDialogoCrearMesa(context, ref, recintoId),
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
      ),
      body: RefreshIndicator(
        color: _Tema.primary,
        onRefresh: () async {
          ref.invalidate(resumenRecintoProvider(recintoId));
          ref.invalidate(mesasPorRecintoProvider(recintoId));
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            resumenAsync.when(
              loading: () => const _BannerCargando(),
              error: (e, _) => _BannerError(mensaje: e.toString()),
              data: (resumen) => _BannerResumen(resumen: resumen),
            ),
            const SizedBox(height: 12),
            mesasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: TextStyle(color: _Tema.errorColor)),
              ),
              data: (mesas) {
                if (mesas.isEmpty) {
                  return _SinMesasView(
                    onAgregar: () =>
                        _mostrarDialogoCrearMesa(context, ref, recintoId),
                  );
                }
                return Column(
                  children: mesas
                      .map((mesa) => _TarjetaMesaCoordinador(
                            mesa: mesa,
                            usuario: usuario,
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Diálogo crear mesa ──────────────────────────────────────────────────────
  void _mostrarDialogoCrearMesa(
      BuildContext context, WidgetRef ref, int recintoId) {
    final ctrlNumero = TextEditingController();
    GeneroMesa generoSeleccionado = GeneroMesa.unica;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nueva mesa / JRV',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrlNumero,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número de mesa',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Género',
                    style:
                        TextStyle(fontSize: 13, color: _Tema.onSurfaceVariant)),
              ),
              const SizedBox(height: 6),
              ...GeneroMesa.values.map((g) => RadioListTile<GeneroMesa>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text(g.dbValue, style: const TextStyle(fontSize: 13)),
                    value: g,
                    groupValue: generoSeleccionado,
                    onChanged: (v) => setS(() => generoSeleccionado = v!),
                  )),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _Tema.primary),
              onPressed: () async {
                final numero = int.tryParse(ctrlNumero.text);
                if (numero == null) return;
                try {
                  await ref.read(crearMesaProvider)(
                      recintoId, numero, generoSeleccionado);
                  ref.invalidate(mesasPorRecintoProvider(recintoId));
                  ref.invalidate(resumenRecintoProvider(recintoId));
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: _Tema.errorColor));
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Diálogo crear veedor (con validación completa) ─────────────────────────
  void _mostrarDialogoCrearVeedor(
      BuildContext context, WidgetRef ref, int recintoId) {
    final ctrlCedula = TextEditingController();
    final ctrlNombres = TextEditingController();
    final ctrlApellidos = TextEditingController();
    final ctrlTelefono = TextEditingController();
    final ctrlCorreo = TextEditingController();
    int? mesaIdSeleccionada;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));
          return AlertDialog(
            title: const Text('Crear veedor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Cédula con validación ecuatoriana ──
                    _CampoForm(
                      ctrl: ctrlCedula,
                      label: 'Cédula de identidad',
                      digitsOnly: true,
                      maxLength: 10,
                      validator: CedulaValidator.validate,
                    ),
                    const SizedBox(height: 10),
                    _CampoForm(
                      ctrl: ctrlNombres,
                      label: 'Nombres completos',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Los nombres son obligatorios'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _CampoForm(
                      ctrl: ctrlApellidos,
                      label: 'Apellidos completos',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Los apellidos son obligatorios'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _CampoForm(
                      ctrl: ctrlTelefono,
                      label: 'Teléfono de contacto',
                      digitsOnly: true,
                      maxLength: 10,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatorio';
                        if (v.length < 9) return 'Teléfono inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // ── Correo electrónico ──
                    _CampoForm(
                      ctrl: ctrlCorreo,
                      label: 'Correo electrónico',
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El correo es obligatorio';
                        }
                        final emailRegex =
                            RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(v.trim())) {
                          return 'Correo electrónico inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // ── Selector de mesa ──
                    mesasAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error cargando mesas: $e'),
                      data: (mesas) => DropdownButtonFormField<int>(
                        value: mesaIdSeleccionada,
                        hint: const Text('Asignar a mesa'),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), isDense: true),
                        validator: (v) =>
                            v == null ? 'Selecciona una mesa' : null,
                        items: mesas
                            .map((m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Text(
                                      'Mesa ${m.numeroMesa} — ${m.genero.dbValue}'),
                                ))
                            .toList(),
                        onChanged: (v) => setS(() => mesaIdSeleccionada = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Aviso de correo de confirmación
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _Tema.successContainer,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: _Tema.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mail_outline,
                              size: 16, color: _Tema.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Se enviará un correo de confirmación para activar la cuenta.',
                              style:
                                  TextStyle(fontSize: 11, color: _Tema.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _Tema.primary),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    await ref.read(crearVeedorProvider)(
                      ctrlCedula.text.trim(),
                      ctrlNombres.text.trim(),
                      ctrlApellidos.text.trim(),
                      ctrlTelefono.text.trim(),
                      ctrlCorreo.text.trim(), // ← NUEVO
                      mesaIdSeleccionada!,
                    );
                    ref.invalidate(veedoresDeRecintoProvider(recintoId));
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Veedor creado · Se envió correo de confirmación'),
                          backgroundColor: _Tema.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: _Tema.errorColor));
                    }
                  }
                },
                child: const Text('Crear y enviar correo'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Banner resumen
// ═════════════════════════════════════════════════════════════════════════════
class _BannerResumen extends StatelessWidget {
  final ResumenRecinto resumen;
  const _BannerResumen({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_Tema.primary, _Tema.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_Tema.cardRadius),
      ),
      child: Row(
        children: [
          _Stat(valor: '${resumen.totalMesas}', etiqueta: 'Mesas'),
          _Div(),
          _Stat(
              valor: '${resumen.mesasConActaAlcalde}',
              etiqueta: 'Actas alcalde'),
          _Div(),
          _Stat(
              valor: '${resumen.mesasConActaPrefecto}',
              etiqueta: 'Actas prefecto'),
          _Div(),
          _Stat(
            valor: '${resumen.actasPendientes}',
            etiqueta: 'Pendientes',
            destacar: resumen.actasPendientes > 0,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String valor, etiqueta;
  final bool destacar;
  const _Stat(
      {required this.valor, required this.etiqueta, this.destacar = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                  color: destacar ? const Color(0xFFFFCC02) : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                )),
            Text(etiqueta,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 36,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _BannerCargando extends StatelessWidget {
  const _BannerCargando();
  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        decoration: BoxDecoration(
          color: _Tema.primary,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
        ),
        child: const Center(
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
      );
}

class _BannerError extends StatelessWidget {
  final String mensaje;
  const _BannerError({required this.mensaje});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _Tema.errorContainer,
          borderRadius: BorderRadius.circular(_Tema.cardRadius),
        ),
        child: Text(mensaje, style: TextStyle(color: _Tema.errorColor)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Tarjeta de mesa
// ═════════════════════════════════════════════════════════════════════════════
class _TarjetaMesaCoordinador extends ConsumerWidget {
  final MesaJrv mesa;
  final Usuario usuario;

  const _TarjetaMesaCoordinador({required this.mesa, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasDeMesaProvider(mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_Tema.cardRadius),
        border: Border.all(color: _Tema.outline, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _Tema.surfaceContainerLow,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.how_to_vote_outlined,
                    size: 16, color: _Tema.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa ${mesa.numeroMesa} — ${mesa.genero.dbValue}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _Tema.primary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _mostrarReasignar(context, ref, mesa),
                  child: const Icon(Icons.swap_horiz,
                      size: 18, color: _Tema.primary),
                ),
              ],
            ),
          ),
          actasAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: $e',
                  style: TextStyle(color: _Tema.errorColor, fontSize: 12)),
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
                  _FilaActaCoordinador(
                    etiqueta: 'Acta de Alcalde',
                    acta: actaAlcalde,
                    onTap: () => _irAFormulario(
                        context, ref, Dignidad.alcalde, actaAlcalde),
                  ),
                  Divider(height: 1, thickness: 1, color: _Tema.outline),
                  _FilaActaCoordinador(
                    etiqueta: 'Acta de Prefecto',
                    acta: actaPrefecto,
                    onTap: () => _irAFormulario(
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

  Future<void> _irAFormulario(BuildContext context, WidgetRef ref,
      Dignidad dignidad, Acta? actaExistente) async {
    final orgsAsync = ref.read(organizacionesPorDignidadProvider(dignidad));
    final orgs = orgsAsync.maybeWhen(
        data: (d) => d, orElse: () => <OrganizacionPolitica>[]);

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActaFormScreen(
          mesaId: mesa.id,
          mesaNombre: mesa.numeroMesa.toString(),
          recintoNombre: 'Recinto ${mesa.recintoId}',
          dignidad: dignidad,
          totalSufragantes: 300,
          organizaciones: orgs,
          userId: usuario.id,
          actaExistente: actaExistente,
        ),
      ),
    );
    ref.invalidate(actasDeMesaProvider(mesa.id));
  }

  void _mostrarReasignar(BuildContext context, WidgetRef ref, MesaJrv mesa) {
    showDialog(
      context: context,
      builder: (ctx) => _DialogoReasignar(mesa: mesa, ref: ref),
    );
  }
}

class _FilaActaCoordinador extends StatelessWidget {
  final String etiqueta;
  final Acta? acta;
  final VoidCallback onTap;

  const _FilaActaCoordinador({
    required this.etiqueta,
    required this.acta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              registrada
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              size: 18,
              color: registrada ? _Tema.success : _Tema.greyLight,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiqueta,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  if (acta?.gpsLat != null)
                    Text(
                      'GPS: ${acta!.gpsLat!.toStringAsFixed(5)}, ${acta!.gpsLng!.toStringAsFixed(5)}',
                      style: TextStyle(fontSize: 10, color: _Tema.greyLight),
                    ),
                ],
              ),
            ),
            _BadgeEstadoActa(acta: acta),
            const SizedBox(width: 8),
            Icon(
              registrada ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 16,
              color: _Tema.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeEstadoActa extends StatelessWidget {
  final Acta? acta;
  const _BadgeEstadoActa({required this.acta});

  @override
  Widget build(BuildContext context) {
    if (acta == null) {
      return _badge('Pendiente', _Tema.warningColor, _Tema.warningContainer,
          _Tema.warningColor.withOpacity(0.3));
    }
    return switch (acta!.estado) {
      EstadoActa.ingresada => _badge(
          'Ingresada', _Tema.primary, _Tema.surfaceContainerLow, _Tema.outline),
      EstadoActa.revisada => _badge('Revisada', _Tema.success,
          _Tema.successContainer, _Tema.success.withOpacity(0.3)),
      EstadoActa.conNovedad => _badge('Con novedad', _Tema.errorColor,
          _Tema.errorContainer, _Tema.errorColor.withOpacity(0.3)),
    };
  }

  Widget _badge(String label, Color color, Color bg, Color border) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Diálogo reasignar veedor
// ═════════════════════════════════════════════════════════════════════════════
class _DialogoReasignar extends ConsumerStatefulWidget {
  final MesaJrv mesa;
  final WidgetRef ref;
  const _DialogoReasignar({required this.mesa, required this.ref});

  @override
  ConsumerState<_DialogoReasignar> createState() => _DialogoReasignarState();
}

class _DialogoReasignarState extends ConsumerState<_DialogoReasignar> {
  String? _veedorSeleccionado;

  @override
  Widget build(BuildContext context) {
    final veedoresAsync =
        ref.watch(veedoresDeRecintoProvider(widget.mesa.recintoId));

    return AlertDialog(
      title: Text(
        'Reasignar veedor — Mesa ${widget.mesa.numeroMesa}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      content: veedoresAsync.when(
        loading: () => const SizedBox(
            height: 60, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Error: $e'),
        data: (veedores) {
          if (veedores.isEmpty) {
            return const Text('No hay veedores disponibles en este recinto.',
                style: TextStyle(fontSize: 13));
          }
          return DropdownButtonFormField<String>(
            value: _veedorSeleccionado,
            hint: const Text('Seleccionar veedor'),
            decoration: const InputDecoration(
                border: OutlineInputBorder(), isDense: true),
            items: veedores
                .map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text('${v.nombres} ${v.apellidos}',
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _veedorSeleccionado = v),
          );
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _Tema.primary),
          onPressed: _veedorSeleccionado == null
              ? null
              : () async {
                  try {
                    await ref.read(reasignarVeedorProvider)(
                        _veedorSeleccionado!, widget.mesa.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Veedor reasignado correctamente'),
                          backgroundColor: _Tema.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: _Tema.errorColor));
                    }
                  }
                },
          child: const Text('Reasignar'),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Widgets auxiliares
// ═════════════════════════════════════════════════════════════════════════════
class _SinMesasView extends StatelessWidget {
  final VoidCallback onAgregar;
  const _SinMesasView({required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: _Tema.greyLight),
            const SizedBox(height: 16),
            Text('Sin mesas registradas',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _Tema.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Agrega las mesas de este recinto.',
                style: TextStyle(fontSize: 13, color: _Tema.greyLight)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar mesa'),
              style: FilledButton.styleFrom(backgroundColor: _Tema.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Campo de formulario con validación ───────────────────────────────────────
class _CampoForm extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool digitsOnly;
  final int? maxLength;
  final bool required;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;

  const _CampoForm({
    required this.ctrl,
    required this.label,
    this.digitsOnly = false,
    this.maxLength,
    this.required = true,
    this.validator,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType:
          keyboard ?? (digitsOnly ? TextInputType.number : TextInputType.text),
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? '$label es obligatorio'
                  : null
              : null),
    );
  }
}
