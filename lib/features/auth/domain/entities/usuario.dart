// lib/features/auth/domain/entities/usuario.dart
class Usuario {
  final String id; // UUID de auth.users
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final RolUsuario rol;
  final bool debeCambiarPassword;
  final int? recintoId;

  Usuario({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.debeCambiarPassword,
    this.recintoId,
  });
}

enum RolUsuario { veedor, coordinadorRecinto, coordinadorProvincial }

extension RolUsuarioX on RolUsuario {
  String get dbValue {
    switch (this) {
      case RolUsuario.veedor:
        return 'veedor';
      case RolUsuario.coordinadorRecinto:
        return 'coordinador_recinto';
      case RolUsuario.coordinadorProvincial:
        return 'coordinador_provincial';
    }
  }

  static RolUsuario fromDb(String value) {
    switch (value) {
      case 'veedor':
        return RolUsuario.veedor;
      case 'coordinador_recinto':
        return RolUsuario.coordinadorRecinto;
      case 'coordinador_provincial':
        return RolUsuario.coordinadorProvincial;
      default:
        throw ArgumentError('Rol desconocido: $value');
    }
  }
}