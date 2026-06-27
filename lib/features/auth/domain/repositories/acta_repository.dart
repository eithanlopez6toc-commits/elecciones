// lib/features/auth/domain/repositories/acta_repository.dart
import 'dart:io';
import '../entities/acta.dart';

abstract class ActaRepository {
  /// Sube la foto del acta al storage y devuelve la URL pública del archivo.
  Future<String> subirFotoActa(File foto);

  /// Crea o actualiza el registro del acta.
  Future<void> guardarActa(Acta acta);

  /// Útil para detectar si una mesa ya tiene actas registradas
  /// (evita doble registro) y para la pantalla de revisión.
  Future<List<Acta>> obtenerActasPorMesa(int mesaId);
}