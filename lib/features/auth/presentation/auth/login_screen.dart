import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/login_controller.dart';
import '../../domain/entities/usuario.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _cedulaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // NUEVO: Variable para manejar el rol seleccionado (Simulado o adaptado a tu lógica si es necesario)
  String? _selectedRol;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();

    final usuario = await ref
        .read(loginControllerProvider.notifier)
        .login(
          _cedulaCtrl.text.trim(),
          _passwordCtrl.text,
        );

    if (!mounted || usuario == null) return;

    if (usuario.debeCambiarPassword) {
      Navigator.of(context).pushReplacementNamed('/cambiar-password');
      return;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Fondo ultra claro con textura de puntos sutil (Color base del mockup)
      backgroundColor: const Color(0xFFF8F9FC), 
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, // Íconos de la barra de estado oscuros
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Principal Contenedor del Login
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
                          // Header con el Escudo/Check y Texto Voter Portal
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF3422CD),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Voter Portal',
                                style: TextStyle(
                                  color: Color(0xFF3422CD),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Ícono central flotante del mockup
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.unarchive_outlined,
                              color: Color(0xFF3422CD),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Título y Subtítulo
                          const Text(
                            'Acceda a su portal de votación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ingrese sus credenciales oficiales para continuar de forma segura.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF475467),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // --- FORMULARIO DE ENTRADA ---
                          
                          // 1. Dropdown de Selección de Rol
                          _buildLabel('Seleccionar Rol'),
                          const SizedBox(height: 6),
                          _buildDropdownField(),
                          const SizedBox(height: 20),

                          // 2. ID de Usuario (Cédula)
                          _buildLabel('ID del Usuario'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _cedulaCtrl,
                            hint: '10 dígitos numéricos',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 3. Contraseña + Enlace "¿Olvidó su contraseña?" alineados
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Contraseña'),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/olvide-password'),
                                child: const Text(
                                  '¿Olvidó su contraseña?',
                                  style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _passwordCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF98A2B3),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Manejo de Error de tu lógica original
                          if (state.hasError)
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
                                    child: Text(
                                      _mensajeError('${state.error}'),
                                      style: const TextStyle(
                                          color: Color(0xFFB42318),
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Botón Iniciar Sesión (Azul/Violeta Eléctrico de la captura)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: state.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF3422CD),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2B1CB1),
                                      elevation: 2,
                                      shadowColor: const Color(0xFF3422CD).withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Opción de registrarse/solicitar acceso adaptada al estilo claro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta? ',
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/solicitar-acceso'),
                                child: const Text(
                                  'Solicitar acceso',
                                  style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- BANNER DE INFORMACIÓN INFERIOR (Verde Menta del Mockup) ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FADF), // Fondo menta exacto
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6EE7B7).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info,
                            color: Color(0xFF065F46),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Este sistema utiliza encriptación de grado militar y autenticación de dos factores para proteger su integridad democrática.',
                              style: TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper para las etiquetas oscuras del diseño claro
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Input fields limpios con bordes grises y focus violeta
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 20),
        suffixIcon: suffix,
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
          borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5),
        ),
      ),
    );
  }

  // Selector de Rol Estilizado (Dropdown) según la captura
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedRol,
      hint: Row(
        children: const [
          Icon(Icons.account_circle_outlined, color: Color(0xFF667085), size: 20),
          SizedBox(width: 10),
          Text('Seleccionar un rol', style: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)),
        ],
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF667085)),
      decoration: InputDecoration(
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
          borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5),
        ),
      ),
      items: <String>['Coordinador Provincial', 'Coordinador Recinto', 'Veedor']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Color(0xFF101828), fontSize: 14)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRol = newValue;
        });
      },
    );
  }

  String _mensajeError(String error) {
    if (error.contains('Cédula inválida')) return 'Cédula inválida. Verifica el número.';
    if (error.contains('Invalid credentials')) return 'Cédula o contraseña incorrectos.';
    if (error.contains('rate_limit')) return 'Demasiados intentos. Espera un momento.';
    if (error.contains('No se encontró un perfil')) return 'Usuario no registrado en el sistema.';
    return 'Error al ingresar. Intenta de nuevo.';
  }
}