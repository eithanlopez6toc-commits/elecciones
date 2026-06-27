// domain/entities/recinto.dart
class Recinto {
  final int id;
  final String nombre;
  final String provincia;
  final String canton;
  final String parroquia;
  final String? direccion;

  Recinto({
    required this.id,
    required this.nombre,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    this.direccion,
  });
}