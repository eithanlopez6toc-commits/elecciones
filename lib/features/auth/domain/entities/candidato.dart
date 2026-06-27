// domain/entities/candidato.dart
class Candidato {
  final int id;
  final int organizacionId;
  final String nombre;
  final String dignidad;

  Candidato({
    required this.id,
    required this.organizacionId,
    required this.nombre,
    required this.dignidad,
  });
}