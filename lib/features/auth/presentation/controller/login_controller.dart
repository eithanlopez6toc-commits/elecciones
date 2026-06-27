// lib/features/auth/presentation/controller/login_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../domain/entities/usuario.dart';

// 🔥 Proveedor global para conocer el usuario logueado en cualquier pantalla
final usuarioActualProvider = StateProvider<Usuario?>((ref) => null);

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
          ref.read(usuarioActualProvider.notifier).state = usuario;
          state = AsyncData(usuario);
          return usuario;
        },
      );
    } catch (e) {
      state = AsyncError('Error de conexión: ${e.toString()}', StackTrace.current);
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(supabaseClientProvider).auth.signOut();
    } catch (_) {}
    ref.read(usuarioActualProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}