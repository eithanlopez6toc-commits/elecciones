class Recinto {
  final String id;
  final String canton;
  final String parroquia;
  final String nombre;
  final String? coordinadorId;

  const Recinto({
    required this.id,
    required this.canton,
    required this.parroquia,
    required this.nombre,
    this.coordinadorId,
  });
}