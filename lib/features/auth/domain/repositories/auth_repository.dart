import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<Either<Failure, Usuario>> login(String cedula, String password);
}