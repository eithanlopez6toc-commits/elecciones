// lib/features/auth/data/models/usuario_model.dart
import 'dart:convert';
import '../../domain/entities/usuario.dart';

class UsuarioModel {
  static Map<String, dynamic> toMap(Usuario usuario) {
    return {
      'id': usuario.id,
      'cedula': usuario.cedula,
      'nombre': usuario.nombres,
      'apellido': usuario.apellidos,
      'telefono': usuario.telefono,
      'correo': usuario.correo,
      'rol': usuario.rol.dbValue,
      'debe_cambiar_password': usuario.debeCambiarPassword,
      'recinto_id': usuario.recintoId,
    };
  }

  static Usuario fromMap(Map<String, dynamic> data, {String? correo}) {
    return Usuario(
      id: data['id'] as String,
      cedula: data['cedula'] as String,
      nombres: data['nombre'] as String,
      apellidos: data['apellido'] as String,
      telefono: data['telefono'] as String? ?? '',
      correo: correo ?? data['correo'] as String? ?? '',
      rol: RolUsuarioX.fromDb(data['rol'] as String),
      debeCambiarPassword: data['debe_cambiar_password'] as bool? ?? false,
      recintoId: data['recinto_id'] as int?,
    );
  }

  // --- NUEVO: cache local ---
  static String toJson(Usuario usuario) => jsonEncode(toMap(usuario));

  static Usuario fromJson(String json) => fromMap(jsonDecode(json) as Map<String, dynamic>);
}