// lib/features/auth/data/repositories/acta_repository_impl.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../models/acta_model.dart';

class ActaRepositoryImpl implements ActaRepository {
  final SupabaseClient _supabase;

  ActaRepositoryImpl(this._supabase);

  @override
  Future<String> subirFotoActa(File foto) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${foto.path.split('/').last}';
    await _supabase.storage
        .from(SupabaseConstants.actasBucket)
        .upload(fileName, foto);
    return _supabase.storage
        .from(SupabaseConstants.actasBucket)
        .getPublicUrl(fileName);
  }

  @override
  // ★ FIX: ahora retorna Acta con el id asignado por Supabase,
  //         necesario para navegar a vista previa tras guardar.
  Future<Acta> guardarActa(Acta acta) async {
    final data = ActaModel.toMap(acta);

    if (acta.id == 0) {
      // INSERT — Supabase retorna la fila completa con el id generado
      final resultado = await _supabase
          .from(SupabaseConstants.actasTable)
          .insert(data)
          .select()
          .single();
      return ActaModel.fromMap(resultado);
    } else {
      // UPDATE
      final resultado = await _supabase
          .from(SupabaseConstants.actasTable)
          .update(data)
          .eq('id', acta.id)
          .select()
          .single();
      return ActaModel.fromMap(resultado);
    }
  }

  @override
  Future<List<Acta>> obtenerActasPorMesa(int mesaId) async {
    final resultado = await _supabase
        .from(SupabaseConstants.actasTable)
        .select()
        .eq('mesa_id', mesaId);
    return (resultado as List)
        .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}
