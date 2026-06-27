import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client_provider.dart';

class OlvidePasswordScreen extends ConsumerStatefulWidget {
  const OlvidePasswordScreen({super.key});

  @override
  ConsumerState<OlvidePasswordScreen> createState() =>
      _OlvidePasswordScreenState();
}

class _OlvidePasswordScreenState extends ConsumerState<OlvidePasswordScreen> {
  final _correoCtrl = TextEditingController();
  bool _cargando = false;
  bool _enviado = false;
  String? _error;

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarRecuperacion() async {
    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty || !correo.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.resetPasswordForEmail(
        correo,
        redirectTo: 'https://controlelectoral.app/reset-password',
      );
      setState(() => _enviado = true);
    } on AuthException catch (e) {
      setState(() => _error = _mensajeError(e.message));
    } catch (e) {
      setState(() => _error = _mensajeError(e.toString()));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String e) {
    final lower = e.toLowerCase();
    if (lower.contains('user_not_found') || lower.contains('invalid')) {
      return 'No existe una cuenta con ese correo.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Demasiados intentos. Espera unos minutos.';
    }
    return 'No se pudo enviar el correo. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Fondo claro del mockup
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, // Íconos de estado oscuros
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contenedor tipo Tarjeta Blanca
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE4E7EC),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Encabezado institucional
                        Row(
                          children: const [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF1D4ED8),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Voter Portal',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Control de estados visuales
                        _enviado ? _buildSuccessState() : _buildFormState(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer institucional de la Comisión Electoral
                  Column(
                    children: [
                      const Text(
                        'Election Commission',
                        style: TextStyle(
                          color: Color(0xFF344054),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Privacy Policy', style: TextStyle(color: Color(0xFF475467), fontSize: 12)),
                          SizedBox(width: 12),
                          Text('Technical Support', style: TextStyle(color: Color(0xFF475467), fontSize: 12)),
                          SizedBox(width: 12),
                          Text('Terms of Service', style: TextStyle(color: Color(0xFF475467), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '© 2024 Election Commission. All rights reserved.',
                        style: TextStyle(
                          color: Color(0xFF039855),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ícono central redondeado azul claro
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Color(0xFF1D4ED8),
            size: 28,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Recuperar\nContraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ingresa tu correo para recibir un enlace de recuperación',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF475467),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        // Etiquetas del campo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Correo de Usuario',
              style: TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'REQUERIDO',
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Input con el icono de la carta incorporado
        TextField(
          controller: _correoCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Escribe tu correo',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF667085), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
            ),
          ),
        ),

        // Manejo de errores adaptado al diseño limpio
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECDCA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFD92D20), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB42318), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Botón Enviar Instrucciones
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1D4ED8),
                    strokeWidth: 2.5,
                  ),
                )
              : ElevatedButton(
                  onPressed: _enviarRecuperacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F43CD),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Enviar Instrucciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE4E7EC), thickness: 1),
        const SizedBox(height: 16),

        // Volver al inicio de sesión
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF1D4ED8)),
          label: const Text(
            'Volver al inicio de sesión',
            style: TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Banner informativo inferior azul grisáceo sutil
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline_rounded, color: Color(0xFF344054), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Por seguridad, si el correo de usuario es válido, recibirás un correo con las instrucciones de recuperación en la dirección registrada en el padrón electoral.',
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF039855),
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Revisa tu bandeja de entrada y sigue el enlace enviado para restablecer las credenciales.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF475467),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Si no lo encuentras, no olvides revisar tu carpeta de spam.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Volver al login',
              style: TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}