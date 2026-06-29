// lib/features/auth/domain/repositories/acta_repository.dart
import 'dart:io';
import '../entities/acta.dart';

abstract class ActaRepository {
  Future<String> subirFotoActa(File foto);

  // ★ FIX: retorna la Acta guardada con su id real (necesario para vista previa)
  Future<Acta> guardarActa(Acta acta);

  Future<List<Acta>> obtenerActasPorMesa(int mesaId);
}