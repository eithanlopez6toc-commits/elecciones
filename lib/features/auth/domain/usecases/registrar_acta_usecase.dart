// lib/features/auth/domain/usecases/registrar_acta_usecase.dart
import 'dart:io';
import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class ActaInconsistenteException implements Exception {
  final String message;
  ActaInconsistenteException(this.message);
  @override
  String toString() => message;
}

class RegistrarActaUseCase {
  final ActaRepository repository;
  RegistrarActaUseCase(this.repository);

  /// [foto] es opcional aquí para poder testear el usecase sin
  /// depender de dart:io File en pantallas que no la tengan aún.
  Future<void> call({required Acta acta, File? foto}) async {
    if (!acta.esConsistente) {
      throw ActaInconsistenteException(
        'La suma de votos supera el total de sufragantes registrados.',
      );
    }

    String? urlFotoActa = acta.urlFotoActa;
    if (foto != null) {
      urlFotoActa = await repository.subirFotoActa(foto);
    }

    final actaFinal = acta.copyWith(urlFotoActa: urlFotoActa);
    await repository.guardarActa(actaFinal);
  }
}