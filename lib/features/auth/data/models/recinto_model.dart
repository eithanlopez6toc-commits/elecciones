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
      id: data['id'] as int,
      nombre: data['nombre'] as String,
      provincia: data['provincia'] as String,
      canton: data['canton'] as String,
      parroquia: data['parroquia'] as String,
      direccion: data['direccion'] as String?,
    );
  }
}