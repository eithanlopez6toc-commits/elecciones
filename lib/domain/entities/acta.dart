import 'organizacion_politica.dart';

enum EstadoActa { pendiente, registrada, corregida }

class Acta {
  final String id;
  final String mesaId;
  final Dignidad dignidad;
  final Map<String, int> votosPorOrganizacion; // org_id -> cantidad
  final int votosNulos;
  final int votosBlancos;
  final int totalSufragantes;
  final String? fotoId;
  final double? gpsLat;
  final double? gpsLng;
  final EstadoActa estado;
  final String creadoPor;
  final DateTime fecha;

  const Acta({
    required this.id,
    required this.mesaId,
    required this.dignidad,
    required this.votosPorOrganizacion,
    required this.votosNulos,
    required this.votosBlancos,
    required this.totalSufragantes,
    this.fotoId,
    this.gpsLat,
    this.gpsLng,
    required this.estado,
    required this.creadoPor,
    required this.fecha,
  });

  /// Regla de negocio clave: suma de votos no puede superar el total de sufragantes
  bool get esConsistente {
    final sumaVotos = votosPorOrganizacion.values.fold(0, (a, b) => a + b) +
        votosNulos +
        votosBlancos;
    return sumaVotos <= totalSufragantes;
  }
}