import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'features/auth/presentation/auth/auth_gate.dart';
import 'features/auth/presentation/auth/login_screen.dart';
import 'features/auth/presentation/auth/olvide_password_screen.dart';
import 'features/auth/presentation/auth/cambiar_password_screen.dart';
import 'features/auth/presentation/veedor/veedor_panel_screen.dart';
import 'features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart';
import 'features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );
  runApp(const ProviderScope(child: ControlElectoralApp()));
}

// ═════════════════════════════════════════════════════════════════════════════
// APP
// ═════════════════════════════════════════════════════════════════════════════
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
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _manejarDeepLink(uri);
    });
    _appLinks.uriLinkStream.listen((uri) {
      _manejarDeepLink(uri);
    });
  }

  Future<void> _manejarDeepLink(Uri uri) async {
    debugPrint('🔗 Deep link recibido: $uri');
    final fragment = uri.fragment;
    if (fragment.isEmpty) return;

    final params = Uri.splitQueryString(fragment);
    final accessToken = params['access_token'];
    final refreshToken = params['refresh_token'];
    final type = params['type'];

    if (!mounted) return;

    if (type == 'magiclink') {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (r) => false);
      final ctx = navigatorKey.currentState?.overlay?.context;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content:
              Text('✅ Cuenta activada. Ingresa con tu contraseña temporal.'),
          backgroundColor: Color(0xFF039855),
          duration: Duration(seconds: 4),
        ));
      }
      return;
    }

    if (accessToken == null || refreshToken == null) return;

    try {
      await Supabase.instance.client.auth.setSession(refreshToken);
    } catch (e) {
      debugPrint('❌ Error estableciendo sesión: $e');
      return;
    }

    if (!mounted) return;

    if (type == 'recovery' || type == 'invite') {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/cambiar-password', (r) => false);
    } else if (type == 'signup') {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (r) => false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = navigatorKey.currentState?.overlay?.context;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('✅ Cuenta confirmada. Ya puedes iniciar sesión.'),
            backgroundColor: Color(0xFF039855),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Electoral',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/veedor': (_) => const VeedorPanelScreen(),
        '/olvide-password': (_) => const OlvidePasswordScreen(),
        '/cambiar-password': (_) => const CambiarPasswordScreen(),
        '/provincial': (_) => const CoordinadorProvincialPanelScreen(),
        '/coordinador-recinto': (_) => const CoordinadorRecintoPanelScreen(),
      },
    );
  }
}
