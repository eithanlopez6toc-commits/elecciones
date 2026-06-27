import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../controller/login_controller.dart';

class CambiarPasswordScreen extends ConsumerStatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  ConsumerState<CambiarPasswordScreen> createState() =>
      _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends ConsumerState<CambiarPasswordScreen> {
  final _nuevaCtrl = TextEditingController();
  final _actualCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  Future<void> _guardar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final usuario = ref.read(usuarioActualProvider)!;

      // 1. Re-autenticamos con la contraseña actual para validarla
      //    (Supabase no valida la "old password" dentro de updateUser)
      await supabase.auth.signInWithPassword(
        email: '${usuario.cedula}@controlelectoral.local',
        password: _actualCtrl.text,
      );

      // 2. Cambia la contraseña en Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: _nuevaCtrl.text),
      );

      // 3. Marca el registro como ya no pendiente
      await supabase
          .from(SupabaseConstants.usuariosTable)
          .update({'debe_cambiar_password': false})
          .eq('id', usuario.id);

      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambia tu contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _actualCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña actual'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nuevaCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            ),
            const SizedBox(height: 24),
            if (_cargando)
              const CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}