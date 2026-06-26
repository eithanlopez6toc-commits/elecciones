enum Dignidad { alcalde, prefecto }

class OrganizacionPolitica {
  final String id;
  final String nombre;
  final Dignidad dignidad;

  const OrganizacionPolitica({
    required this.id,
    required this.nombre,
    required this.dignidad,
  });
}