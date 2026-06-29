// lib/features/auth/presentation/controller/login_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/usuario.dart';
import '../../data/models/usuario_model.dart';
import '../../data/datasources/usuario_cache_service.dart';
import '../../providers/auth_providers.dart';
import '../../data/datasources/supabase_client_provider.dart';

class UsuarioNotifier extends StateNotifier<Usuario?> {
  UsuarioNotifier() : super(null) {
    _restoreFromSession();
  }

  Future<void> _restoreFromSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('id', session.user.id)
          .single()
          .timeout(const Duration(seconds: 6));

      final usuario = UsuarioModel.fromMap(
        data,
        correo: session.user.email ?? '',
      );

      state = usuario;
      await UsuarioCacheService.guardar(usuario);
    } catch (e) {
      // Sin internet u otro error: restauramos el último usuario válido
      // que quedó guardado en disco la última vez que hubo conexión.
      final cacheado = await UsuarioCacheService.leer();
      if (cacheado != null && cacheado.id == session.user.id) {
        state = cacheado;
        return;
      }

      // Último recurso: metadatos de auth (normalmente incompletos).
      final meta = session.user.userMetadata;
      state = Usuario(
        id: session.user.id,
        cedula: meta?['cedula'] as String? ?? '',
        nombres: meta?['nombres'] as String? ?? '',
        apellidos: meta?['apellidos'] as String? ?? '',
        telefono: meta?['telefono'] as String? ?? '',
        correo: session.user.email ?? '',
        rol: _rolFromMetadata(meta?['rol'] as String?),
        debeCambiarPassword: meta?['debe_cambiar_password'] as bool? ?? false,
        recintoId: meta?['recinto_id'] as int?,
      );
    }
  }

  RolUsuario _rolFromMetadata(String? rol) {
    switch (rol) {
      case 'coordinador_provincial':
        return RolUsuario.coordinadorProvincial;
      case 'coordinador_recinto':
        return RolUsuario.coordinadorRecinto;
      case 'veedor':
        return RolUsuario.veedor;
      default:
        return RolUsuario.veedor;
    }
  }

  void setUsuario(Usuario u) {
    state = u;
    UsuarioCacheService.guardar(u);
  }

  void clear() => state = null;
}

final usuarioActualProvider =
    StateNotifierProvider<UsuarioNotifier, Usuario?>((ref) {
  return UsuarioNotifier();
});

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, Usuario?>(() => LoginController());

class LoginController extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    return null;
  }

  Future<Usuario?> login(String cedula, String password) async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(cedula, password);

      return result.fold(
        (failure) {
          state = AsyncError(failure.message, StackTrace.current);
          return null;
        },
        (usuario) {
          ref.read(usuarioActualProvider.notifier).setUsuario(usuario);
          state = AsyncData(usuario);
          return usuario;
        },
      );
    } catch (e) {
      state =
          AsyncError('Error de conexión: ${e.toString()}', StackTrace.current);
      return null;
    }
  }

  /// Cierra sesión SIN esperar la respuesta del servidor.
  /// Limpia todo el estado local primero (instantáneo) y deja el
  /// signOut() remoto corriendo en background con timeout corto,
  /// para que el botón nunca se quede "colgado" sin conexión.
  Future<void> logout() async {
    // 1. Limpiar estado local primero — esto es lo que la UI necesita
    //    para navegar a /login de inmediato.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rol_usuario');
      await prefs.remove('usuario_id');
    } catch (_) {}

    await UsuarioCacheService.limpiar();
    ref.read(usuarioActualProvider.notifier).clear();
    state = const AsyncData(null);

    // 2. signOut remoto en background, no bloquea la navegación.
    unawaited(
      ref.read(supabaseClientProvider).auth.signOut().timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      ).catchError((_) {}),
    );
  }
}