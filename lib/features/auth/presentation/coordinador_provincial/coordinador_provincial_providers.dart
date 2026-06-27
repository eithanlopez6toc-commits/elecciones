// lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/recinto_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/acta_model.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/acta.dart';

// ─── Todos los recintos ───────────────────────────────────────────────────────
final todosLosRecintosProvider = FutureProvider<List<Recinto>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.recintosTable)
      .select()
      .order('nombre');
  return (res as List)
      .map((r) => RecintoModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Resumen de avance por recinto ───────────────────────────────────────────
class ResumenRecintoProv {
  final Recinto recinto;
  final int totalMesas;
  final int actasAlcalde;
  final int actasPrefecto;

  const ResumenRecintoProv({
    required this.recinto,
    required this.totalMesas,
    required this.actasAlcalde,
    required this.actasPrefecto,
  });

  int get totalActas => actasAlcalde + actasPrefecto;
  int get pendientes => (totalMesas * 2) - totalActas;
  double get porcentaje => totalMesas == 0 ? 0 : totalActas / (totalMesas * 2);
}

final resumenPorRecintoProvider =
    FutureProvider.family<ResumenRecintoProv, Recinto>((ref, recinto) async {
  final supabase = ref.watch(supabaseClientProvider);

  final mesasRes = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select('id')
      .eq('recinto_id', recinto.id);
  final mesaIds = (mesasRes as List).map((r) => r['id'] as int).toList();

  if (mesaIds.isEmpty) {
    return ResumenRecintoProv(
      recinto: recinto,
      totalMesas: 0,
      actasAlcalde: 0,
      actasPrefecto: 0,
    );
  }

  final actasRes = await supabase
      .from(SupabaseConstants.actasTable)
      .select('dignidad')
      .inFilter('mesa_id', mesaIds);

  int alcalde = 0, prefecto = 0;
  for (final row in actasRes as List) {
    final d = row['dignidad'] as String?;
    if (d == 'Alcalde') alcalde++;
    if (d == 'Prefecto') prefecto++;
  }

  return ResumenRecintoProv(
    recinto: recinto,
    totalMesas: mesaIds.length,
    actasAlcalde: alcalde,
    actasPrefecto: prefecto,
  );
});

// ─── Detalle de actas de un recinto (con GPS) ────────────────────────────────
final actasDeRecintoProvider =
    FutureProvider.family<List<Acta>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final mesasRes = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select('id')
      .eq('recinto_id', recintoId);
  final mesaIds = (mesasRes as List).map((r) => r['id'] as int).toList();
  if (mesaIds.isEmpty) return [];

  final res = await supabase
      .from(SupabaseConstants.actasTable)
      .select()
      .inFilter('mesa_id', mesaIds)
      .order('created_at', ascending: false);
  return (res as List)
      .map((r) => ActaModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Dashboard: votos consolidados por candidato ─────────────────────────────
class VotosCandidato {
  final int candidatoId;
  final String nombre;
  final String dignidad;
  final String organizacion;
  final int totalVotos;
  // Campo opcional para filtrar por recinto en el dashboard
  final String? recintoNombre;

  const VotosCandidato({
    required this.candidatoId,
    required this.nombre,
    required this.dignidad,
    required this.organizacion,
    required this.totalVotos,
    this.recintoNombre,
  });
}

final dashboardVotosProvider =
    FutureProvider<List<VotosCandidato>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase.from('votos_candidatos').select('''
    candidato_id,
    cantidad_votos,
    candidatos!inner(
      nombre,
      dignidad,
      organizaciones_politicas!inner(nombre)
    )
  ''');

  final Map<int, VotosCandidato> mapa = {};
  for (final row in res as List) {
    final cid = row['candidato_id'] as int;
    final votos = row['cantidad_votos'] as int;
    final cand = row['candidatos'] as Map<String, dynamic>;
    final org = cand['organizaciones_politicas'] as Map<String, dynamic>;

    if (mapa.containsKey(cid)) {
      mapa[cid] = VotosCandidato(
        candidatoId: cid,
        nombre: mapa[cid]!.nombre,
        dignidad: mapa[cid]!.dignidad,
        organizacion: mapa[cid]!.organizacion,
        totalVotos: mapa[cid]!.totalVotos + votos,
      );
    } else {
      mapa[cid] = VotosCandidato(
        candidatoId: cid,
        nombre: cand['nombre'] as String,
        dignidad: cand['dignidad'] as String,
        organizacion: org['nombre'] as String,
        totalVotos: votos,
      );
    }
  }

  final lista = mapa.values.toList()
    ..sort((a, b) => b.totalVotos.compareTo(a.totalVotos));
  return lista;
});

// ─── Mesas de un recinto ─────────────────────────────────────────────────────
final mesasDeRecintoProvProv =
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

// ─── Crear recinto (ahora incluye numJrv) ────────────────────────────────────
final crearRecintoProvider = Provider<
    Future<Recinto> Function(
      String canton,
      String parroquia,
      String nombre,
      String? direccion,
      int numJrv, // ← NUEVO
    )>((ref) {
  return (canton, parroquia, nombre, direccion, numJrv) async {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from(SupabaseConstants.recintosTable)
        .insert({
          'canton': canton,
          'parroquia': parroquia,
          'nombre': nombre,
          'provincia': 'Ecuador',
          'num_jrv': numJrv, // ← NUEVO
          if (direccion != null) 'direccion': direccion,
        })
        .select()
        .single();
    return RecintoModel.fromMap(res);
  };
});

// ─── Crear coordinador de recinto (ahora incluye correo) ─────────────────────
final crearCoordinadorRecintoProvider = Provider<
    Future<void> Function(
      String cedula,
      String nombres,
      String apellidos,
      String telefono,
      String correo, // ← NUEVO
      int recintoId,
    )>((ref) {
  return (cedula, nombres, apellidos, telefono, correo, recintoId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo, // ← NUEVO
      'rol': 'coordinador_recinto',
      'recinto_id': recintoId,
    });
  };
});

// ─── Coordinadores de recinto ─────────────────────────────────────────────────
final coordinadoresRecintoProvider = FutureProvider<List<Usuario>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from('usuarios')
      .select()
      .eq('rol', 'coordinador_recinto')
      .order('nombre');
  return (res as List)
      .map((r) => UsuarioModel.fromMap(r as Map<String, dynamic>, correo: ''))
      .toList();
});
