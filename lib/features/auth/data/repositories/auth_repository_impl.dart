// lib/features/auth/data/repositories/auth_repository_impl.dart
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
    print('🔐 Intentando login con: $email'); // ← agrega esto

    final authResponse = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    print('✅ Auth response: ${authResponse.user?.id}'); // ← y esto

    if (authResponse.user == null) {
      return Left(ServerFailure('Error en la autenticación'));
    }

    print('📋 Buscando perfil...'); // ← y esto
    final resultado = await _supabase
        .from(SupabaseConstants.usuariosTable)
        .select()
        .eq('id', authResponse.user!.id)
        .maybeSingle();

    print('👤 Perfil encontrado: $resultado'); // ← y esto

    if (resultado == null) {
      await _supabase.auth.signOut();
      return Left(ServerFailure('Usuario no registrado'));
    }

    final usuario = UsuarioModel.fromMap(
      resultado,
      correo: authResponse.user!.email ?? '',
    );
    return Right(usuario);

  } on AuthException catch (e) {
    print('❌ AuthException: ${e.message}'); // ← y esto
    return Left(ServerFailure(e.message));
  } catch (e) {
    print('💥 Error inesperado: $e'); // ← y esto
    try { await _supabase.auth.signOut(); } catch (_) {}
    return Left(ServerFailure('Error inesperado: ${e.toString()}'));
  }
}
}