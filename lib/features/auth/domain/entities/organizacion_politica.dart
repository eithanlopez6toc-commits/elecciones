// lib/features/auth/domain/entities/organizacion_politica.dart
class OrganizacionPolitica {
  final int id;
  final String nombre;
  final String listaNumero;
  final String? candidatoNombre; // nombre del candidato para la dignidad consultada

  const OrganizacionPolitica({
    required this.id,
    required this.nombre,
    required this.listaNumero,
    this.candidatoNombre,
  });
}