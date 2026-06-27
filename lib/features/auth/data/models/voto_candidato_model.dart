// data/models/voto_candidato_model.dart
import '../../domain/entities/voto_candidato.dart';

class VotoCandidatoModel {
  static Map<String, dynamic> toMap(VotoCandidato voto) {
    return {
      'acta_id': voto.actaId,
      'candidato_id': voto.candidatoId,
      'cantidad_votos': voto.cantidadVotos,
    };
  }

  static VotoCandidato fromMap(Map<String, dynamic> data) {
    return VotoCandidato(
      id: data['id'] as int,
      actaId: data['acta_id'] as int,
      candidatoId: data['candidato_id'] as int,
      cantidadVotos: data['cantidad_votos'] as int,
    );
  }
}