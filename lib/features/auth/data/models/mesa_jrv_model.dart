// data/models/mesa_jrv_model.dart
import '../../domain/entities/mesa_jrv.dart';

class MesaJrvModel {
  static Map<String, dynamic> toMap(MesaJrv mesa) {
    return {
      'id': mesa.id,              // ← AGREGADO
      'recinto_id': mesa.recintoId,
      'numero_mesa': mesa.numeroMesa,
      'genero': mesa.genero.dbValue,
    };
  }

  static MesaJrv fromMap(Map<String, dynamic> data) {
    return MesaJrv(
      id: data['id'] as int,
      recintoId: data['recinto_id'] as int,
      numeroMesa: data['numero_mesa'] as int,
      genero: GeneroMesaX.fromDb(data['genero'] as String),
    );
  }
}