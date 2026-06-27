// lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../domain/entities/usuario.dart';
import '../controller/login_controller.dart';
import '../veedor/acta_form_screen.dart';
import '../veedor/veedor_providers.dart';
import 'coordinador_recinto_providers.dart';

class CoordinadorRecintoPanelScreen extends ConsumerWidget {
  const CoordinadorRecintoPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider);
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // El recinto del coordinador viene en recintoId del perfil
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
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
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
              if (context.mounted)
                Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1B5E20),
        onRefresh: () async {
          ref.invalidate(resumenRecintoProvider(recintoId));
          ref.invalidate(mesasPorRecintoProvider(recintoId));
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Banner resumen
            resumenAsync.when(
              loading: () => const _BannerCargando(),
              error: (e, _) => _BannerError(mensaje: e.toString()),
              data: (resumen) => _BannerResumen(resumen: resumen),
            ),
            const SizedBox(height: 12),

            // Lista de mesas
            mesasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
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

  // ── Dialogo crear mesa ──────────────────────────────────────────────────────
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Género',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
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
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20)),
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
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red),
                    );
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

  // ── Dialogo crear veedor ────────────────────────────────────────────────────
  void _mostrarDialogoCrearVeedor(
      BuildContext context, WidgetRef ref, int recintoId) {
    final ctrlCedula = TextEditingController();
    final ctrlNombres = TextEditingController();
    final ctrlApellidos = TextEditingController();
    final ctrlTelefono = TextEditingController();
    int? mesaIdSeleccionada;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));
          return AlertDialog(
            title: const Text('Crear veedor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CampoTexto(
                      ctrl: ctrlCedula,
                      label: 'Cédula',
                      digitsOnly: true,
                      maxLength: 10),
                  const SizedBox(height: 10),
                  _CampoTexto(ctrl: ctrlNombres, label: 'Nombres'),
                  const SizedBox(height: 10),
                  _CampoTexto(ctrl: ctrlApellidos, label: 'Apellidos'),
                  const SizedBox(height: 10),
                  _CampoTexto(
                      ctrl: ctrlTelefono, label: 'Teléfono', digitsOnly: true),
                  const SizedBox(height: 10),
                  mesasAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error cargando mesas: $e'),
                    data: (mesas) => DropdownButtonFormField<int>(
                      value: mesaIdSeleccionada,
                      hint: const Text('Asignar a mesa'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20)),
                onPressed: mesaIdSeleccionada == null
                    ? null
                    : () async {
                        try {
                          await ref.read(crearVeedorProvider)(
                            ctrlCedula.text.trim(),
                            ctrlNombres.text.trim(),
                            ctrlApellidos.text.trim(),
                            ctrlTelefono.text.trim(),
                            mesaIdSeleccionada!,
                          );
                          ref.invalidate(veedoresDeRecintoProvider(recintoId));
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Veedor creado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red),
                            );
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

// ─────────────────────────────────────────
// Banner resumen
// ─────────────────────────────────────────
class _BannerResumen extends StatelessWidget {
  final ResumenRecinto resumen;
  const _BannerResumen({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
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
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(12),
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
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(mensaje, style: TextStyle(color: Colors.red.shade700)),
      );
}

// ─────────────────────────────────────────
// Tarjeta de mesa con sus actas
// ─────────────────────────────────────────
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.how_to_vote_outlined,
                    size: 16, color: Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa ${mesa.numeroMesa} — ${mesa.genero.dbValue}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                // Botón reasignar veedor
                GestureDetector(
                  onTap: () => _mostrarReasignar(context, ref, mesa),
                  child: const Icon(Icons.swap_horiz,
                      size: 18, color: Color(0xFF1B5E20)),
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
                  _FilaActaCoordinador(
                    etiqueta: 'Acta de Alcalde',
                    acta: actaAlcalde,
                    onTap: () => _irAFormulario(
                        context, ref, Dignidad.alcalde, actaAlcalde),
                  ),
                  Divider(
                      height: 1, thickness: 0.5, color: Colors.grey.shade200),
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
    // Cargar veedores del recinto para mostrarlos en el dropdown
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
              color: registrada ? Colors.green.shade600 : Colors.grey.shade400,
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
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
            _BadgeEstadoActa(acta: acta),
            const SizedBox(width: 8),
            Icon(
              registrada ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 16,
              color: const Color(0xFF1B5E20),
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
      return _badge('Pendiente', Colors.orange.shade700, Colors.orange.shade50,
          Colors.orange.shade200);
    }
    return switch (acta!.estado) {
      EstadoActa.ingresada => _badge('Ingresada', Colors.blue.shade700,
          Colors.blue.shade50, Colors.blue.shade200),
      EstadoActa.revisada => _badge('Revisada', Colors.green.shade700,
          Colors.green.shade50, Colors.green.shade200),
      EstadoActa.conNovedad => _badge('Con novedad', Colors.red.shade700,
          Colors.red.shade50, Colors.red.shade200),
    };
  }

  Widget _badge(String label, Color color, Color bg, Color border) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      );
}

// ─────────────────────────────────────────
// Diálogo reasignar veedor
// ─────────────────────────────────────────
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
          style:
              FilledButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
          onPressed: _veedorSeleccionado == null
              ? null
              : () async {
                  try {
                    await ref.read(reasignarVeedorProvider)(
                        _veedorSeleccionado!, widget.mesa.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veedor reasignado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
          child: const Text('Reasignar'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────
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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Sin mesas registradas',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Agrega las mesas de este recinto.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar mesa'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool digitsOnly;
  final int? maxLength;

  const _CampoTexto({
    required this.ctrl,
    required this.label,
    this.digitsOnly = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
