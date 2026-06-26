import 'organizacion_politica.dart';

class Candidato {
  final String id;
  final String nombre;
  final String organizacionId;
  final Dignidad dignidad;

  const Candidato({
    required this.id,
    required this.nombre,
    required this.organizacionId,
    required this.dignidad,
  });
}