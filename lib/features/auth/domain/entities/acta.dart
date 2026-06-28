// lib/features/auth/domain/entities/acta.dart
// ─── REEMPLAZA tu archivo actual con este ────────────────────────────────────

// CAMBIO: dignidades reales del proyecto (alcalde y prefecto)
enum Dignidad { alcalde, prefecto }

extension DignidadX on Dignidad {
  String get dbValue {
    switch (this) {
      case Dignidad.alcalde:
        return 'Alcalde';
      case Dignidad.prefecto:
        return 'Prefecto';
    }
  }

  String get etiqueta {
    switch (this) {
      case Dignidad.alcalde:
        return 'Alcalde';
      case Dignidad.prefecto:
        return 'Prefecto';
    }
  }

  static Dignidad fromDb(String value) {
    switch (value) {
      case 'Alcalde':
        return Dignidad.alcalde;
      case 'Prefecto':
        return Dignidad.prefecto;
      default:
        throw ArgumentError('Dignidad desconocida: $value');
    }
  }
}

enum EstadoActa { ingresada, revisada, conNovedad }

extension EstadoActaX on EstadoActa {
  String get dbValue {
    switch (this) {
      case EstadoActa.ingresada:
        return 'INGRESADA';
      case EstadoActa.revisada:
        return 'REVISADA';
      case EstadoActa.conNovedad:
        return 'CON NVEDAD'; // typo intencional para coincidir con el CHECK de la BD
    }
  }

  static EstadoActa fromDb(String value) {
    switch (value) {
      case 'INGRESADA':
        return EstadoActa.ingresada;
      case 'REVISADA':
        return EstadoActa.revisada;
      case 'CON NVEDAD':
        return EstadoActa.conNovedad;
      default:
        throw ArgumentError('Estado desconocido: $value');
    }
  }
}

class Acta {
  final int id;
  final int mesaId;
  final String? usuarioId;
  final Dignidad? dignidad;
  final Map<String, int>? votosPorOrganizacion;
  final int votosBlancos;
  final int votosNulos;
  final int? totalSufragantes;
  final String? urlFotoActa;
  final double? gpsLat;
  final double? gpsLng;
  final EstadoActa estado;
  final DateTime createdAt;
  final bool pendienteSync;

  const Acta({
    required this.id,
    required this.mesaId,
    this.usuarioId,
    this.dignidad,
    this.votosPorOrganizacion,
    required this.votosBlancos,
    required this.votosNulos,
    this.totalSufragantes,
    this.urlFotoActa,
    this.gpsLat,
    this.gpsLng,
    required this.estado,
    required this.createdAt,
    this.pendienteSync = false,
  });

  bool get esConsistente {
    if (totalSufragantes == null) return true;
    final sumaOrganizaciones =
        votosPorOrganizacion?.values.fold<int>(0, (a, b) => a + b) ?? 0;
    return (sumaOrganizaciones + votosBlancos + votosNulos) <=
        totalSufragantes!;
  }

  Acta copyWith({
    int? id,
    int? mesaId,
    String? usuarioId,
    Dignidad? dignidad,
    Map<String, int>? votosPorOrganizacion,
    int? votosBlancos,
    int? votosNulos,
    int? totalSufragantes,
    String? urlFotoActa,
    double? gpsLat,
    double? gpsLng,
    EstadoActa? estado,
    DateTime? createdAt,
    bool? pendienteSync,
  }) {
    return Acta(
      id: id ?? this.id,
      mesaId: mesaId ?? this.mesaId,
      usuarioId: usuarioId ?? this.usuarioId,
      dignidad: dignidad ?? this.dignidad,
      votosPorOrganizacion: votosPorOrganizacion ?? this.votosPorOrganizacion,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      votosNulos: votosNulos ?? this.votosNulos,
      totalSufragantes: totalSufragantes ?? this.totalSufragantes,
      urlFotoActa: urlFotoActa ?? this.urlFotoActa,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      pendienteSync: pendienteSync ?? this.pendienteSync,
    );
  }
}
