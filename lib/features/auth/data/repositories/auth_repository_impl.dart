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
  Future<Either<Failure, Usuario>> login(
      String cedula, String password) async {
    try {
      final email = '$cedula@controlelectoral.local';
      print('🔐 Intentando login con email: $email');
      print('🔑 Password recibido: "$password"');

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Auth OK - uid: ${authResponse.user?.id}');
      print('📧 Email en auth: ${authResponse.user?.email}');

      if (authResponse.user == null) {
        return Left(ServerFailure('Error en la autenticación'));
      }

      print('📋 Buscando en tabla: ${SupabaseConstants.usuariosTable}');
      print('🔍 Buscando por id: ${authResponse.user!.id}');

      final resultado = await _supabase
          .from(SupabaseConstants.usuariosTable)
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      print('👤 Resultado de la tabla: $resultado');

      if (resultado == null) {
        await _supabase.auth.signOut();
        return Left(ServerFailure('Usuario no registrado en la tabla'));
      }

      final usuario = UsuarioModel.fromMap(
        resultado,
        correo: authResponse.user!.email ?? '',
      );
      print('🎉 Usuario mapeado: ${usuario.nombres} - rol: ${usuario.rol}');
      return Right(usuario);
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message} | statusCode: ${e.statusCode}');
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      print('💥 Error inesperado: $e');
      print('📍 StackTrace: $st');

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