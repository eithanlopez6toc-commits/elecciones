// domain/entities/mesa_jrv.dart
enum GeneroMesa { masculino, femenino, unica }

extension GeneroMesaX on GeneroMesa {
  String get dbValue {
    switch (this) {
      case GeneroMesa.masculino:
        return 'MASCULINO';
      case GeneroMesa.femenino:
        return 'FEMENINO';
      case GeneroMesa.unica:
        return 'UNICA';
    }
  }

  static GeneroMesa fromDb(String value) {
    switch (value) {
      case 'MASCULINO':
        return GeneroMesa.masculino;
      case 'FEMENINO':
        return GeneroMesa.femenino;
      case 'UNICA':
        return GeneroMesa.unica;
      default:
        throw ArgumentError('Género desconocido: $value');
    }
  }
}

class MesaJrv {
  final int id;
  final int recintoId;
  final int numeroMesa;
  final GeneroMesa genero;

  MesaJrv({
    required this.id,
    required this.recintoId,
    required this.numeroMesa,
    required this.genero,
  });
}