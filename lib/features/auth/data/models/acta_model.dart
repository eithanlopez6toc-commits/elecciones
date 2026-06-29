// data/models/acta_model.dart
import '../../domain/entities/acta.dart';

class ActaModel {
  static Map<String, dynamic> toMap(Acta acta) {
    return {
      'id': acta.id,                                   // ← AGREGADO
      'mesa_id': acta.mesaId,
      'usuario_id': acta.usuarioId,
      'dignidad': acta.dignidad?.name,
      'votos_por_organizacion': acta.votosPorOrganizacion,
      'votos_blancos': acta.votosBlancos,
      'votos_nulos': acta.votosNulos,
      'total_sufragantes': acta.totalSufragantes,
      'url_foto_acta': acta.urlFotoActa,
      'gps_lat': acta.gpsLat,
      'gps_lng': acta.gpsLng,
      'estado': acta.estado.dbValue,
      'created_at': acta.createdAt.toIso8601String(),  // ← AGREGADO
      'pendiente_sync': acta.pendienteSync,             // ← AGREGADO (útil para cache)
    };
  }

  static Acta fromMap(Map<String, dynamic> data) {
    return Acta(
      id: data['id'] as int,
      mesaId: data['mesa_id'] as int,
      usuarioId: data['usuario_id'] as String?,
      dignidad: data['dignidad'] != null
          ? Dignidad.values.byName(data['dignidad'] as String)
          : null,
      votosPorOrganizacion: data['votos_por_organizacion'] != null
          ? Map<String, int>.from(data['votos_por_organizacion'] as Map)
          : null,
      votosBlancos: data['votos_blancos'] as int,
      votosNulos: data['votos_nulos'] as int,
      totalSufragantes: data['total_sufragantes'] as int?,
      urlFotoActa: data['url_foto_acta'] as String?,
      gpsLat: (data['gps_lat'] as num?)?.toDouble(),
      gpsLng: (data['gps_lng'] as num?)?.toDouble(),
      estado: EstadoActaX.fromDb(data['estado'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      pendienteSync: data['pendiente_sync'] as bool? ?? false,
    );
  }
}