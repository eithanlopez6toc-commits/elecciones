// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'dart:io' show SocketException;
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, Usuario>> login(String cedula, String password) async {
    try {
      final email = '$cedula@controlelectoral.local';

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return Left(ServerFailure('Error en la autenticación'));
      }

      final resultado = await _supabase
          .from(SupabaseConstants.usuariosTable)
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      if (resultado == null) {
        await _supabase.auth.signOut();
        return Left(ServerFailure('Usuario no registrado en la tabla'));
      }

      final usuario = UsuarioModel.fromMap(
        resultado,
        correo: authResponse.user!.email ?? '',
      );
      return Right(usuario);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      final esErrorDeRed = e is SocketException ||
          e.toString().contains('SocketException') ||
          e.toString().contains('network') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException');

      if (!esErrorDeRed) {
        try {
          await _supabase.auth.signOut();
        } catch (_) {}
      }

      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
