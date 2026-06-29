import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../domain/entities/usuario.dart';
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
  final _confirmarCtrl = TextEditingController();
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  bool _esPasswordValida(String p) {
    return p.length >= 8 &&
        p.contains(RegExp(r'[A-Z]')) &&
        p.contains(RegExp(r'[0-9]'));
  }

  Future<void> _guardar() async {
    final nueva = _nuevaCtrl.text;
    final confirmar = _confirmarCtrl.text;

    if (nueva != confirmar) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }
    if (!_esPasswordValida(nueva)) {
      setState(
          () => _error = 'Mínimo 8 caracteres, una mayúscula y un número.');
      return;
    }
    if (nueva == 'Ecuador2026') {
      setState(() =>
          _error = 'No puedes usar la contraseña inicial. Elige una nueva.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);

      // 1. Cambiar contraseña en Auth
      await supabase.auth.updateUser(UserAttributes(password: nueva));

      // 2. Intentar marcar debe_cambiar_password = false si hay usuario en provider
      //    (flujo normal: login → cambiar password)
      //    Si viene de recovery, el provider puede ser null — no es problema,
      //    Supabase ya actualizó la contraseña correctamente.
      final usuario = ref.read(usuarioActualProvider);
      if (usuario != null) {
        await supabase
            .from(SupabaseConstants.usuariosTable)
            .update({'debe_cambiar_password': false}).eq('id', usuario.id);
      } else {
        // Viene de recovery: buscar el id del usuario autenticado actual
        final authUser = supabase.auth.currentUser;
        if (authUser != null) {
          await supabase
              .from(SupabaseConstants.usuariosTable)
              .update({'debe_cambiar_password': false}).eq('id', authUser.id);
        }
      }

      if (!mounted) return;

      // 3. Redirigir según rol (si hay usuario en provider) o al login (si viene de recovery)
      if (usuario != null) {
        switch (usuario.rol) {
          case RolUsuario.coordinadorProvincial:
            Navigator.of(context).pushReplacementNamed('/provincial');
            break;
          case RolUsuario.coordinadorRecinto:
            Navigator.of(context).pushReplacementNamed('/coordinador-recinto');
            break;
          case RolUsuario.veedor:
            Navigator.of(context).pushReplacementNamed('/veedor');
            break;
        }
      } else {
        // Viene de recovery: cerrar sesión y volver al login
        await supabase.auth.signOut();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contraseña actualizada. Inicia sesión.'),
            backgroundColor: Color(0xFF039855),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = _mensajeError(e.message));
    } catch (e) {
      debugPrint('❌ Error al cambiar password: $e');
      setState(() => _error = 'Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String e) {
    if (e.contains('weak')) {
      return 'Contraseña muy débil. Usa mínimo 8 caracteres.';
    }
    if (e.contains('same')) {
      return 'La nueva contraseña no puede ser igual a la anterior.';
    }
    return 'No se pudo cambiar. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                const Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        color: Color(0xFF3422CD), size: 22),
                    SizedBox(width: 8),
                    Text('Voter Portal',
                        style: TextStyle(
                            color: Color(0xFF3422CD),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),

                // Ícono
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Color(0xFF3422CD), size: 30),
                ),
                const SizedBox(height: 24),

                const Text('Crea tu nueva\ncontraseña',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2)),
                const SizedBox(height: 10),
                const Text(
                    'Por seguridad debes cambiar tu contraseña antes de continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF475467), fontSize: 14, height: 1.4)),
                const SizedBox(height: 32),

                // Campo nueva contraseña
                _buildLabel('Nueva contraseña'),
                const SizedBox(height: 6),
                _buildPasswordField(
                  controller: _nuevaCtrl,
                  hint: 'Mínimo 8 caracteres',
                  obscure: _obscureNueva,
                  onToggle: () =>
                      setState(() => _obscureNueva = !_obscureNueva),
                ),
                const SizedBox(height: 20),

                // Campo confirmar
                _buildLabel('Confirmar contraseña'),
                const SizedBox(height: 6),
                _buildPasswordField(
                  controller: _confirmarCtrl,
                  hint: 'Repite tu nueva contraseña',
                  obscure: _obscureConfirmar,
                  onToggle: () =>
                      setState(() => _obscureConfirmar = !_obscureConfirmar),
                ),
                const SizedBox(height: 8),

                // Reglas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu contraseña debe tener:',
                          style: TextStyle(
                              color: Color(0xFF344054),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('• Al menos 8 caracteres',
                          style: TextStyle(
                              color: Color(0xFF475467), fontSize: 12)),
                      Text('• Al menos una letra mayúscula',
                          style: TextStyle(
                              color: Color(0xFF475467), fontSize: 12)),
                      Text('• Al menos un número',
                          style: TextStyle(
                              color: Color(0xFF475467), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECDCA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFD92D20), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: Color(0xFFB42318), fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // Botón
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _cargando
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF3422CD), strokeWidth: 2.5))
                      : ElevatedButton(
                          onPressed: _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B1CB1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Guardar y continuar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      );

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Color(0xFF667085), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF98A2B3),
              size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5)),
      ),
    );
  }
}
