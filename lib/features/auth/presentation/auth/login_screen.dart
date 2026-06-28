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
        .login(_cedulaCtrl.text.trim(), _passwordCtrl.text);

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

  // ── Modal de error ─────────────────────────────────────────────────────────
  void _mostrarModalError(String mensaje) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.error_outline,
                    color: Color(0xFFD92D20), size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error de acceso',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828)),
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475467),
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B1CB1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Entendido',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet de selección de rol ──────────────────────────────────────
  void _mostrarSelectorRol() {
    final roles = [
      _RolOpcion(
        label: 'Coordinador Provincial',
        descripcion: 'Supervisión general del proceso electoral',
        icon: Icons.account_balance_outlined,
      ),
      _RolOpcion(
        label: 'Coordinador de Recinto',
        descripcion: 'Gestión de mesas y veedores del recinto',
        icon: Icons.location_city_outlined,
      ),
      _RolOpcion(
        label: 'Veedor',
        descripcion: 'Ingreso y seguimiento de actas',
        icon: Icons.how_to_vote_outlined,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill indicador
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E7EC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Seleccionar Rol',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828)),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Elige el rol con el que ingresarás al sistema.',
                style: TextStyle(fontSize: 13, color: Color(0xFF667085)),
              ),
            ),
            const SizedBox(height: 20),
            ...roles.map((rol) {
              final seleccionado = _selectedRol == rol.label;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedRol = rol.label);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? const Color(0xFFF0EEFF)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: seleccionado
                          ? const Color(0xFF3422CD)
                          : const Color(0xFFE4E7EC),
                      width: seleccionado ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? const Color(0xFFE8E7FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                        ),
                        child: Icon(rol.icon,
                            size: 20,
                            color: seleccionado
                                ? const Color(0xFF3422CD)
                                : const Color(0xFF667085)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rol.label,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: seleccionado
                                        ? const Color(0xFF3422CD)
                                        : const Color(0xFF101828))),
                            const SizedBox(height: 2),
                            Text(rol.descripcion,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF667085))),
                          ],
                        ),
                      ),
                      if (seleccionado)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF3422CD), size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final size = MediaQuery.of(context).size;

    // Detecta error y muestra modal (una sola vez por cambio de estado)
    ref.listen(loginControllerProvider, (prev, next) {
      if (next.hasError && next.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mostrarModalError(_mensajeError('${next.error}'));
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── Card principal ──────────────────────────────────────
                    Container(
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
                              Text(
                                'Voter Portal',
                                style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Ícono central
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.unarchive_outlined,
                                color: Color(0xFF3422CD), size: 30),
                          ),
                          const SizedBox(height: 24),

                          // Título y subtítulo
                          const Text(
                            'Acceda a su portal de votación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ingrese sus credenciales oficiales para continuar de forma segura.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF475467),
                                fontSize: 14,
                                height: 1.4),
                          ),
                          const SizedBox(height: 32),

                          // ── Selector de rol (abre Bottom Sheet) ──────────
                          _buildLabel('Seleccionar Rol'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _mostrarSelectorRol,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFD0D5DD)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.account_circle_outlined,
                                      color: Color(0xFF667085),
                                      size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedRol ??
                                          'Seleccionar un rol',
                                      style: TextStyle(
                                          color: _selectedRol != null
                                              ? const Color(0xFF101828)
                                              : const Color(0xFF98A2B3),
                                          fontSize: 14),
                                    ),
                                  ),
                                  const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF667085)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Cédula ────────────────────────────────────────
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

                          // ── Contraseña ────────────────────────────────────
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                                      fontWeight: FontWeight.w600),
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
                              onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Botón iniciar sesión ──────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: state.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF3422CD),
                                        strokeWidth: 2.5),
                                  )
                                : ElevatedButton(
                                    onPressed: _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF2B1CB1),
                                      elevation: 2,
                                      shadowColor: const Color(0xFF3422CD)
                                          .withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Banner inferior ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FADF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF6EE7B7).withOpacity(0.5)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info,
                              color: Color(0xFF065F46), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Este sistema utiliza encriptación de grado militar y autenticación de dos factores para proteger su integridad democrática.',
                              style: TextStyle(
                                  color: Color(0xFF065F46),
                                  fontSize: 12,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500),
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

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
  }

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
        prefixIcon:
            Icon(icon, color: const Color(0xFF667085), size: 20),
        suffixIcon: suffix,
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
                const BorderSide(color: Color(0xFF3422CD), width: 1.5)),
      ),
    );
  }

  String _mensajeError(String error) {
    if (error.contains('Cédula inválida'))
      return 'Cédula inválida. Verifica el número ingresado.';
    if (error.contains('Invalid credentials'))
      return 'Cédula o contraseña incorrectos. Inténtalo de nuevo.';
    if (error.contains('rate_limit'))
      return 'Demasiados intentos fallidos. Espera unos minutos antes de volver a intentarlo.';
    if (error.contains('No se encontró un perfil'))
      return 'Este usuario no está registrado en el sistema.';
    return 'Ocurrió un error al iniciar sesión. Inténtalo de nuevo.';
  }
}

// ── Modelo interno para opciones de rol ──────────────────────────────────────
class _RolOpcion {
  final String label;
  final String descripcion;
  final IconData icon;

  const _RolOpcion({
    required this.label,
    required this.descripcion,
    required this.icon,
  });
}