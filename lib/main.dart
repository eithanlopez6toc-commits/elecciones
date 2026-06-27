import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'features/auth/domain/entities/usuario.dart';
import 'features/auth/presentation/controller/login_controller.dart';
import 'features/auth/presentation/veedor/veedor_panel_screen.dart';
import 'features/auth/presentation/auth/olvide_password_screen.dart';
import 'features/auth/presentation/auth/cambiar_password_screen.dart';
import 'features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart';
import 'features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit, // ← flujo implícito: manda tokens directo
    ),
  );
  runApp(const ProviderScope(child: ControlElectoralApp()));
}

class ControlElectoralApp extends StatefulWidget {
  const ControlElectoralApp({super.key});

  @override
  State<ControlElectoralApp> createState() => _ControlElectoralAppState();
}

class _ControlElectoralAppState extends State<ControlElectoralApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _iniciarDeepLinks();
  }

  void _iniciarDeepLinks() {
    // 1. Captura el link inicial si la app fue abierta DESDE CERRADA por el link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _manejarDeepLink(uri);
    });

    // 2. Captura links mientras la app ya está abierta/en background
    _appLinks.uriLinkStream.listen((uri) {
      _manejarDeepLink(uri);
    });
  }

  Future<void> _manejarDeepLink(Uri uri) async {
    debugPrint('🔗 Deep link recibido: $uri');

    // ── Flujo implícito: #access_token=xxx&refresh_token=xxx&type=recovery ──
    final fragment = uri.fragment;
    if (fragment.isEmpty) {
      debugPrint('⚠️ Deep link sin fragment, se ignora.');
      return;
    }

    final params = Uri.splitQueryString(fragment);
    final accessToken = params['access_token'];
    final refreshToken = params['refresh_token'];
    final type = params['type'];

    debugPrint('📦 Params → type=$type, accessToken=${accessToken != null}, refreshToken=${refreshToken != null}');

    if (accessToken == null || refreshToken == null) {
      debugPrint('⚠️ Faltan tokens en el deep link.');
      return;
    }

    try {
      await Supabase.instance.client.auth.setSession(refreshToken);
      debugPrint('✅ Sesión establecida correctamente.');
    } catch (e) {
      debugPrint('❌ Error estableciendo sesión: $e');
      return;
    }

    if (!mounted) return;

    if (type == 'recovery' || type == 'invite') {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/cambiar-password',
        (route) => false,
      );
    } else if (type == 'signup') {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
      final ctx = navigatorKey.currentState?.overlay?.context;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('✅ Cuenta confirmada. Ya puedes iniciar sesión.'),
          backgroundColor: Color(0xFF039855),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Electoral',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const LoginScreen(),
      routes: {
        '/veedor': (_) => const VeedorPanelScreen(),
        '/olvide-password': (_) => const OlvidePasswordScreen(),
        '/cambiar-password': (_) => const CambiarPasswordScreen(),
        '/provincial': (_) => const CoordinadorProvincialPanelScreen(),
        '/coordinador-recinto': (_) => const CoordinadorRecintoPanelScreen(),
      },
    );
  }
}

// ─── LOGIN SCREEN ─────────────────────────────────────────────────────────────
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

  RolUsuario _rolDesdeDropdown(String rol) {
    switch (rol) {
      case 'Coordinador Provincial':
        return RolUsuario.coordinadorProvincial;
      case 'Coordinador Recinto':
        return RolUsuario.coordinadorRecinto;
      case 'Veedor':
      default:
        return RolUsuario.veedor;
    }
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();

    if (_selectedRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu rol antes de continuar.'),
          backgroundColor: Color(0xFFD92D20),
        ),
      );
      return;
    }

    final usuario = await ref
        .read(loginControllerProvider.notifier)
        .login(_cedulaCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted || usuario == null) return;

    final rolEsperado = _rolDesdeDropdown(_selectedRol!);

    if (usuario.rol != rolEsperado) {
      await ref.read(loginControllerProvider.notifier).logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El rol seleccionado no corresponde a tu cuenta.'),
          backgroundColor: Color(0xFFD92D20),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

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
      backgroundColor: const Color(0xFFF8F9FC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
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
                          Row(
                            children: const [
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
                          const Text('Acceda a su portal de votación',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 10),
                          const Text(
                              'Ingrese sus credenciales oficiales para continuar de forma segura.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF475467),
                                  fontSize: 14,
                                  height: 1.4)),
                          const SizedBox(height: 32),
                          _buildLabel('Seleccionar Rol'),
                          const SizedBox(height: 6),
                          _buildDropdownField(),
                          const SizedBox(height: 20),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Contraseña'),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/olvide-password'),
                                child: const Text('¿Olvidó su contraseña?',
                                    style: TextStyle(
                                        color: Color(0xFF3422CD),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
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
                          if (state.hasError)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFFECDCA)),
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
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: state.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF3422CD),
                                        strokeWidth: 2.5))
                                : ElevatedButton(
                                    onPressed: _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2B1CB1),
                                      elevation: 2,
                                      shadowColor: const Color(0xFF3422CD)
                                          .withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Iniciar Sesión',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tienes cuenta? ',
                                  style: TextStyle(
                                      color: Color(0xFF667085), fontSize: 13)),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/solicitar-acceso'),
                                child: const Text('Solicitar acceso',
                                    style: TextStyle(
                                        color: Color(0xFF3422CD),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          Icon(Icons.info, color: Color(0xFF065F46), size: 20),
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

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      );

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

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedRol,
      hint: Row(
        children: const [
          Icon(Icons.account_circle_outlined,
              color: Color(0xFF667085), size: 20),
          SizedBox(width: 10),
          Text('Seleccionar un rol',
              style: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)),
        ],
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF667085)),
      decoration: InputDecoration(
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
      items: const ['Coordinador Provincial', 'Coordinador Recinto', 'Veedor']
          .map((value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: const TextStyle(
                        color: Color(0xFF101828), fontSize: 14)),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedRol = value),
    );
  }

  String _mensajeError(String error) {
    if (error.contains('Cédula inválida'))
      return 'Cédula inválida. Verifica el número.';
    if (error.contains('Invalid login credentials'))
      return 'Cédula o contraseña incorrectos.';
    if (error.contains('rate_limit'))
      return 'Demasiados intentos. Espera un momento.';
    if (error.contains('no registrado') || error.contains('not found'))
      return 'Usuario no registrado en el sistema.';
    if (error.contains('Email not confirmed'))
      return 'Correo no confirmado. Revisa tu bandeja de entrada.';
    return error;
  }
}