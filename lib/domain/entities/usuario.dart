enum RolUsuario { provincial, coordinadorRecinto, veedor }

class Usuario {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final RolUsuario rol;
  final bool debeCambiarPassword;
  final String? recintoId;

  const Usuario({
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