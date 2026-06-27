// domain/entities/voto_candidato.dart
class VotoCandidato {
  final int id;
  final int actaId;
  final int candidatoId;
  final int cantidadVotos;

  VotoCandidato({
    required this.id,
    required this.actaId,
    required this.candidatoId,
    required this.cantidadVotos,
  });
}