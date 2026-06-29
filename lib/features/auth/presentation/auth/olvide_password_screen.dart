import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/supabase_client_provider.dart';

class OlvidePasswordScreen extends ConsumerStatefulWidget {
  const OlvidePasswordScreen({super.key});

  @override
  ConsumerState<OlvidePasswordScreen> createState() =>
      _OlvidePasswordScreenState();
}

class _OlvidePasswordScreenState extends ConsumerState<OlvidePasswordScreen> {
  final _cedulaCtrl = TextEditingController();
  bool _cargando = false;
  bool _enviado = false;
  String? _error;

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarRecuperacion() async {
    final cedula = _cedulaCtrl.text.trim();
    if (cedula.isEmpty || cedula.length != 10) {
      setState(() => _error = 'Ingresa tu cédula de 10 dígitos.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase.functions.invoke(
        'recuperar-password',
        body: {'cedula': cedula},
      );

      if (response.data['success'] != true) {
        final msg = response.data['error'] ?? 'No se pudo enviar el correo.';
        setState(() => _error = msg);
        return;
      }

      setState(() => _enviado = true);
    } catch (e) {
      setState(() => _error = 'No se pudo enviar el correo. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance,
                          color: Color(0xFF1D4ED8), size: 22),
                      SizedBox(width: 8),
                      Text('Electoral Portal',
                          style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: _enviado ? _buildSuccessState() : _buildFormState(),
                ),
                const SizedBox(height: 20),
                _enviado ? _buildSuccessFooter() : _buildFormFooter(),
              ],
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
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: Color(0xFF1D4ED8), size: 28),
        ),
        const SizedBox(height: 20),
        const Text('Recuperar\nContraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.2)),
        const SizedBox(height: 12),
        const Text(
            'Ingresa tu número de cédula para recibir un enlace de recuperación en tu correo registrado.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFF475467), fontSize: 14, height: 1.4)),
        const SizedBox(height: 32),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Número de Cédula',
              style: TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _cedulaCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
          decoration: InputDecoration(
            hintText: '10 dígitos',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
            prefixIcon: const Icon(Icons.badge_outlined,
                color: Color(0xFF667085), size: 20),
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
                borderSide:
                    const BorderSide(color: Color(0xFF1D4ED8), width: 1.5)),
          ),
        ),
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
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF1D4ED8), strokeWidth: 2.5))
              : ElevatedButton(
                  onPressed: _enviarRecuperacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Enviar Enlace',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver al inicio de sesión',
                style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
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
          decoration: BoxDecoration(
            color: const Color(0xFF00C48C),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('¡Correo Enviado!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 24,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const Text(
            'Hemos enviado las instrucciones de recuperación a tu bandeja de entrada. Por favor, revisa también tu carpeta de spam.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFF475467), fontSize: 14, height: 1.5)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Regresar al Inicio de Sesión',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿No recibiste el correo?',
                style: TextStyle(color: Color(0xFF475467), fontSize: 13)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() {
                _enviado = false;
                _cedulaCtrl.clear();
              }),
              child: const Text('Reintentar',
                  style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFooter() {
    return const Column(
      children: [
        Text('DIGITAL DEMOCRACY CORE • 2024',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF344054),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 13, color: Color(0xFF667085)),
            SizedBox(width: 4),
            Text('Encriptación AES-256',
                style: TextStyle(color: Color(0xFF667085), fontSize: 11)),
            SizedBox(width: 12),
            Icon(Icons.verified_outlined, size: 13, color: Color(0xFF667085)),
            SizedBox(width: 4),
            Text('Certificado Gubernamental',
                style: TextStyle(color: Color(0xFF667085), fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessFooter() {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle, color: Color(0xFF039855), size: 8),
            SizedBox(width: 6),
            Text('ESTADO DEL SISTEMA: OPERATIVO',
                style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Términos de Seguridad',
                style: TextStyle(color: Color(0xFF475467), fontSize: 11)),
            SizedBox(width: 16),
            Text('Protección de Datos',
                style: TextStyle(color: Color(0xFF475467), fontSize: 11)),
          ],
        ),
        SizedBox(height: 8),
        Text('© 2024 Portal Electoral Nacional. Todos los derechos reservados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF98A2B3), fontSize: 10)),
      ],
    );
  }
}
