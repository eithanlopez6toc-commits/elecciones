import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _cedulaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Control Electoral', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 24),
              TextField(
                controller: _cedulaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cédula'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 24),
              if (state.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () => ref.read(loginControllerProvider.notifier)
                      .login(_cedulaCtrl.text.trim(), _passwordCtrl.text),
                  child: const Text('Ingresar'),
                ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('${state.error}',
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}