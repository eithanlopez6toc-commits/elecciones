import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/usuario.dart';
import '../../providers/auth_providers.dart';
import '../../data/datasources/supabase_client_provider.dart';

class UsuarioNotifier extends StateNotifier<Usuario?> {
  UsuarioNotifier() : super(null) {
    _restoreFromSession();
  }

  void _restoreFromSession() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
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

  void setUsuario(Usuario u) => state = u;
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

  Future<void> logout() async {
    try {
      await ref.read(supabaseClientProvider).auth.signOut();
    } catch (_) {}
    ref.read(usuarioActualProvider.notifier).clear();
    state = const AsyncData(null);
  }
}
