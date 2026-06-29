// lib/features/auth/data/models/organizacion_politica_model.dart
import '../../domain/entities/organizacion_politica.dart';

class OrganizacionPoliticaModel extends OrganizacionPolitica {
  const OrganizacionPoliticaModel({
    required super.id,
    required super.nombre,
    required super.listaNumero,
    super.candidatoNombre,
  });

  factory OrganizacionPoliticaModel.fromMap(Map<String, dynamic> map) {
    return OrganizacionPoliticaModel(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      listaNumero: map['lista_numero']?.toString() ?? '',
      candidatoNombre: map['candidato_nombre'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'lista_numero': listaNumero,
      'candidato_nombre': candidatoNombre,
    };
  }
}
