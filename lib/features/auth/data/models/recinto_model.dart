// data/models/recinto_model.dart
import '../../domain/entities/recinto.dart';

class RecintoModel {
  static Map<String, dynamic> toMap(Recinto recinto) {
    return {
      'nombre': recinto.nombre,
      'provincia': recinto.provincia,
      'canton': recinto.canton,
      'parroquia': recinto.parroquia,
      'direccion': recinto.direccion,
    };
  }

  static Recinto fromMap(Map<String, dynamic> data) {
    return Recinto(
      id: data['id'] is int
          ? data['id'] as int
          : int.tryParse(data['id'].toString()) ?? 0,
      nombre: data['nombre'] as String,
      provincia: data['provincia'] as String,
      canton: data['canton'] as String,
      parroquia: data['parroquia'] as String,
      direccion: data['direccion'] as String?,
      numMesas: int.tryParse(data['num_jrv']?.toString() ?? '') ?? 0,
    );
  }
}