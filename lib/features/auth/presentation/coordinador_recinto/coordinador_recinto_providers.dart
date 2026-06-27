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

// ─── Veedores del recinto (para mostrar asignaciones) ────────────────────────
final veedoresDeRecintoProvider =
    FutureProvider.family<List<Usuario>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  // Trae usuarios con rol veedor que tienen mesas asignadas en este recinto
  final res = await supabase
      .from('veedor_mesas')
      .select('''
        usuario_id,
        mesa_id,
        usuarios!inner(*),
        mesas_jrv!inner(recinto_id)
      ''')
      .eq('mesas_jrv.recinto_id', recintoId);

  final vistos = <String>{};
  final lista = <Usuario>[];
  for (final row in res as List) {
    final uid = row['usuario_id'] as String;
    if (!vistos.contains(uid)) {
      vistos.add(uid);
      lista.add(UsuarioModel.fromMap(
        row['usuarios'] as Map<String, dynamic>,
        correo: '',
      ));
    }
  }
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

  int get mesasCompletas =>
      [mesasConActaAlcalde, mesasConActaPrefecto].reduce((a, b) => a < b ? a : b);
  int get actasPendientes => (totalMesas * 2) - mesasConActaAlcalde - mesasConActaPrefecto;
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

// ─── Crear mesa ───────────────────────────────────────────────────────────────
final crearMesaProvider =
    Provider<Future<void> Function(int recintoId, int numero, GeneroMesa genero)>(
        (ref) {
  return (recintoId, numero, genero) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from(SupabaseConstants.mesasJrvTable).insert({
      'recinto_id': recintoId,
      'numero_mesa': numero,
      'genero': genero.dbValue,
    });
  };
});

// ─── Crear cuenta de veedor ───────────────────────────────────────────────────
// Llama a una Edge Function de Supabase para crear el usuario en auth + perfil
final crearVeedorProvider =
    Provider<Future<void> Function(String cedula, String nombres, String apellidos, String telefono, int mesaId)>(
        (ref) {
  return (cedula, nombres, apellidos, telefono, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    // Invoca la Edge Function 'crear-usuario' (ver nota en el SQL)
    await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'rol': 'veedor',
      'mesa_id': mesaId,
    });
  };
});

// ─── Reasignar veedor a mesa ──────────────────────────────────────────────────
final reasignarVeedorProvider =
    Provider<Future<void> Function(String usuarioId, int mesaId)>((ref) {
  return (usuarioId, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    // Elimina asignación anterior y crea la nueva
    await supabase
        .from('veedor_mesas')
        .delete()
        .eq('usuario_id', usuarioId);
    await supabase.from('veedor_mesas').insert({
      'usuario_id': usuarioId,
      'mesa_id': mesaId,
    });
  };
});