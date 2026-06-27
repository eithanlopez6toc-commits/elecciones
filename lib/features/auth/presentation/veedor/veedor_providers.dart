// lib/features/auth/presentation/veedor/veedor_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/acta_model.dart';
import '../../data/models/organizacion_politica_model.dart';

// ─────────────────────────────────────────
// Mesas asignadas al veedor
// ─────────────────────────────────────────
// Busca en la tabla veedor_mesas (relación veedor ↔ mesa)
// Si tienes otra tabla de asignación, ajusta el nombre aquí.
final mesasVeedorProvider =
    FutureProvider.family<List<MesaJrv>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);

  // Opción A: tabla intermedia veedor_mesas
  final resultado = await supabase
      .from('veedor_mesas')
      .select('mesa_id, mesas_jrv(*)')
      .eq('usuario_id', usuarioId);

  return (resultado as List)
      .map((row) =>
          MesaJrvModel.fromMap(row['mesas_jrv'] as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// Actas registradas por el veedor (todas)
// ─────────────────────────────────────────
final actasVeedorProvider =
    FutureProvider.family<List<Acta>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);

  final resultado = await supabase
      .from('actas')
      .select()
      .eq('usuario_id', usuarioId)
      .order('created_at', ascending: false);

  return (resultado as List)
      .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// Actas de una mesa específica
// ─────────────────────────────────────────
final actasPorMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);

  final resultado = await supabase.from('actas').select().eq('mesa_id', mesaId);

  return (resultado as List)
      .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// Organizaciones políticas por dignidad
// ─────────────────────────────────────────
// Precarga las 5 organizaciones para alcalde o prefecto.
// Ajusta el filtro si en tu BD la dignidad está en candidatos o en otra tabla.
final organizacionesPorDignidadProvider =
    FutureProvider.family<List<OrganizacionPolitica>, Dignidad>(
        (ref, dignidad) async {
  final supabase = ref.watch(supabaseClientProvider);

  // Trae organizaciones que tienen candidatos para esa dignidad
  final resultado = await supabase
      .from('organizaciones_politicas')
      .select('''
        id,
        nombre,
        lista_numero,
        candidatos!inner(dignidad)
      ''')
      .eq('candidatos.dignidad', _dignidadToDb(dignidad))
      .order('lista_numero');

  return (resultado as List)
      .map((row) =>
          OrganizacionPoliticaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

String _dignidadToDb(Dignidad d) {
  switch (d) {
    case Dignidad.alcalde:
      return 'Alcalde';
    case Dignidad.prefecto:
      return 'Prefecto';
  }
}
