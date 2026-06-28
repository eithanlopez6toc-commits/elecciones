// lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/acta_model.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/acta.dart';

// ─── Mesas del recinto ────────────────────────────────────────────────────────
final mesasPorRecintoProvider =
    FutureProvider.family<List<MesaJrv>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select()
      .eq('recinto_id', recintoId)
      .order('numero_mesa');
  return (res as List)
      .map((r) => MesaJrvModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Actas de una mesa ────────────────────────────────────────────────────────
final actasDeMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.actasTable)
      .select()
      .eq('mesa_id', mesaId);
  return (res as List)
      .map((r) => ActaModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Veedor + info de mesa asignada ──────────────────────────────────────────
class VeedorConMesa {
  final Usuario usuario;
  final int? mesaId;
  final int? numeroMesa;

  const VeedorConMesa({
    required this.usuario,
    this.mesaId,
    this.numeroMesa,
  });

  /// Disponible = no tiene ninguna mesa asignada actualmente.
  bool get disponible => mesaId == null;
}

// ─── Veedores del recinto (clasificados por disponibilidad) ─────────────────
// IMPORTANTE: para que "disponible" funcione, la columna mesa_id en
// veedor_mesas debe permitir NULL, y reasignarVeedorProvider /
// liberarVeedorProvider deben dejar mesa_id en null en vez de borrar la fila
// cuando se libera a un veedor sin asignarle otra mesa.
final veedoresDeRecintoProvider =
    FutureProvider.family<List<VeedorConMesa>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase.from('veedor_mesas').select('''
        usuario_id,
        mesa_id,
        usuarios!inner(*),
        mesas_jrv!inner(recinto_id, numero_mesa)
      ''').eq('mesas_jrv.recinto_id', recintoId);

  final vistos = <String>{};
  final lista = <VeedorConMesa>[];
  for (final row in res as List) {
    final uid = row['usuario_id'] as String;
    if (!vistos.contains(uid)) {
      vistos.add(uid);
      final mesaJrv = row['mesas_jrv'] as Map<String, dynamic>?;
      lista.add(VeedorConMesa(
        usuario: UsuarioModel.fromMap(
          row['usuarios'] as Map<String, dynamic>,
          correo: '',
        ),
        mesaId: row['mesa_id'] as int?,
        numeroMesa: mesaJrv?['numero_mesa'] as int?,
      ));
    }
  }

  // Disponibles primero, no disponibles después.
  lista.sort((a, b) {
    if (a.disponible == b.disponible) return 0;
    return a.disponible ? -1 : 1;
  });

  return lista;
});

// ─── Resumen de avance del recinto ───────────────────────────────────────────
class ResumenRecinto {
  final int totalMesas;
  final int mesasConActaAlcalde;
  final int mesasConActaPrefecto;

  const ResumenRecinto({
    required this.totalMesas,
    required this.mesasConActaAlcalde,
    required this.mesasConActaPrefecto,
  });

  int get mesasCompletas => [mesasConActaAlcalde, mesasConActaPrefecto]
      .reduce((a, b) => a < b ? a : b);
  int get actasPendientes =>
      (totalMesas * 2) - mesasConActaAlcalde - mesasConActaPrefecto;
}

final resumenRecintoProvider =
    FutureProvider.family<ResumenRecinto, int>((ref, recintoId) async {
  final mesas = await ref.watch(mesasPorRecintoProvider(recintoId).future);
  if (mesas.isEmpty) {
    return const ResumenRecinto(
        totalMesas: 0, mesasConActaAlcalde: 0, mesasConActaPrefecto: 0);
  }

  final supabase = ref.watch(supabaseClientProvider);
  final mesaIds = mesas.map((m) => m.id).toList();

  final res = await supabase
      .from(SupabaseConstants.actasTable)
      .select('mesa_id, dignidad')
      .inFilter('mesa_id', mesaIds);

  int alcalde = 0, prefecto = 0;
  for (final row in res as List) {
    final d = row['dignidad'] as String?;
    if (d == 'Alcalde') alcalde++;
    if (d == 'Prefecto') prefecto++;
  }

  return ResumenRecinto(
    totalMesas: mesas.length,
    mesasConActaAlcalde: alcalde,
    mesasConActaPrefecto: prefecto,
  );
});

// ─── Crear cuenta de veedor ───────────────────────────────────────────────────
final crearVeedorProvider = Provider<
    Future<void> Function(String cedula, String nombre, String apellido,
        String telefono, String correo, int mesaId)>((ref) {
  return (cedula, nombre, apellido, telefono, correo, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    final response = await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
      'rol': 'veedor',
      'mesa_id': mesaId,
    });

    if (response.status != 200) {
      final mensaje = response.data?['error'] ??
          response.data?['message'] ??
          'Error desconocido (status ${response.status})';
      throw Exception(mensaje);
    }
  };
});

// ─── Editar/corregir acta (sin restricción para coordinador) ─────────────────
final editarActaProvider = Provider<
    Future<void> Function({
      required int actaId,
      required Map<String, dynamic> campos,
    })>((ref) {
  return ({required actaId, required campos}) async {
    final supabase = ref.read(supabaseClientProvider);
    final updates = {
      ...campos,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase
        .from(SupabaseConstants.actasTable)
        .update(updates)
        .eq('id', actaId);
  };
});

// ─── Reasignar veedor a mesa ──────────────────────────────────────────────────
final reasignarVeedorProvider =
    Provider<Future<void> Function(String usuarioId, int mesaId)>((ref) {
  return (usuarioId, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('veedor_mesas').delete().eq('usuario_id', usuarioId);
    await supabase.from('veedor_mesas').insert({
      'usuario_id': usuarioId,
      'mesa_id': mesaId,
    });
  };
});

// ─── Liberar veedor (queda disponible, sin mesa) ─────────────────────────────
final liberarVeedorProvider =
    Provider<Future<void> Function(String usuarioId)>((ref) {
  return (usuarioId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase
        .from('veedor_mesas')
        .update({'mesa_id': null}).eq('usuario_id', usuarioId);
  };
});
