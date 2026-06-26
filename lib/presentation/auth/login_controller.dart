import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/appwrite_client_provider.dart';
import '../../core/utils/cedula_validator.dart';

class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String cedula, String password) async {
    if (!CedulaValidator.isValid(cedula)) {
      state = AsyncError('Cédula inválida', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    final account = ref.read(accountProvider);

    state = await AsyncValue.guard(() async {
      await account.createEmailPasswordSession(
        email: '$cedula@controlelectoral.local', // o el correo real si lo registras así
        password: password,
      );
    });
  }
}

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, void>(LoginController.new);