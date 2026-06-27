// lib/features/auth/presentation/controller/login_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../../../core/utils/cedula_validator.dart';
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
    // 1. Validación de cédula ecuatoriana antes de ir al servidor
    if (!CedulaValidator.isValid(cedula)) {
      state = AsyncError('La cédula ingresada no es válida', StackTrace.current);
      return null;
    }

    // 2. Cambiamos el estado a cargando para la UI
    state = const AsyncLoading();

    // 3. Capturamos el resultado del repositorio (ya migrado a Supabase)
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(cedula, password);

      return result.fold(
        (failure) {
          state = AsyncError(failure.message, StackTrace.current);
          return null;
        },
        (usuario) {
          // Guardamos el usuario en el estado global
          ref.read(usuarioActualProvider.notifier).state = usuario;

          // Seteamos el estado final como exitoso
          state = AsyncData(usuario);
          return usuario;
        },
      );
    } catch (e) {
      state = AsyncError('Error de conexión: ${e.toString()}', StackTrace.current);
      return null;
    }
  }

  // 🚪 Método útil para cuando el usuario cierre sesión
  Future<void> logout() async {
    try {
      await ref.read(supabaseClientProvider).auth.signOut();
    } catch (_) {
      // si falla el signOut remoto, igual limpiamos el estado local
    }
    ref.read(usuarioActualProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}