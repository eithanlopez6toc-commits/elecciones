import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/login_controller.dart';
import '../veedor/veedor_panel_screen.dart';
import '../../presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart';
import '../../presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _Cargando();
        }

        final event = snapshot.data!;

        final session = (event.event == AuthChangeEvent.tokenRefreshed ||
                event.event == AuthChangeEvent.userUpdated)
            ? Supabase.instance.client.auth.currentSession
            : event.session;

        if (session == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(usuarioActualProvider.notifier).clear();
          });
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: _getRol(session.user.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _Cargando();
            }
            final rol = snap.data;
            switch (rol) {
              case 'coordinador_provincial':
                return const CoordinadorProvincialPanelScreen();
              case 'coordinador_recinto':
                return const CoordinadorRecintoPanelScreen();
              case 'veedor':
                return const VeedorPanelScreen();
              default:
                return const LoginScreen();
            }
          },
        );
      },
    );
  }

  Future<String?> _getRol(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('usuarios')
          .select('rol')
          .eq('id', userId)
          .single()
          .timeout(const Duration(seconds: 5));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rol_usuario', data['rol'] as String);
      await prefs.setString('usuario_id', userId);

      return data['rol'] as String?;
    } catch (e) {
      debugPrint('❌ Sin internet, leyendo rol local: $e');
      final prefs = await SharedPreferences.getInstance();
      final rolLocal = prefs.getString('rol_usuario');
      final idLocal = prefs.getString('usuario_id');
      if (idLocal == userId && rolLocal != null) {
        return rolLocal;
      }
      return null;
    }
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}