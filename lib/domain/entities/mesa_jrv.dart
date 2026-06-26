class MesaJrv {
  final String id;
  final String recintoId;
  final int numeroMesa;
  final String? veedorId;

  const MesaJrv({
    required this.id,
    required this.recintoId,
    required this.numeroMesa,
    this.veedorId,
  });
}