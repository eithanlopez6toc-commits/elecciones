// data/models/organizacion_politica_model.dart
import '../../domain/entities/organizacion_politica.dart';

class OrganizacionPoliticaModel {
  static Map<String, dynamic> toMap(OrganizacionPolitica org) {
    return {
      'nombre': org.nombre,
      'lista_numero': org.listaNumero,
    };
  }

  static OrganizacionPolitica fromMap(Map<String, dynamic> data) {
    return OrganizacionPolitica(
      id: data['id'] as int,
      nombre: data['nombre'] as String,
      listaNumero: data['lista_numero'] as String,
    );
  }
}