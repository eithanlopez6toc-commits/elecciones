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

        // ── CASO: sin sesión (puede ser logout real O fallo de red al refrescar token) ──
        if (session == null) {
          return FutureBuilder<_CachedAuth?>(
            future: _getCachedAuth(),
            builder: (context, cacheSnap) {
              if (cacheSnap.connectionState == ConnectionState.waiting) {
                return const _Cargando();
              }

              final cached = cacheSnap.data;

              // Si es un logout EXPLÍCITO, el LoginController.logout() ya
              // limpió las prefs, así que cached será null y vamos a Login.
              if (cached == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(usuarioActualProvider.notifier).clear();
                });
                return const LoginScreen();
              }

              // Hay caché de un rol/usuario: probablemente solo fue un fallo
              // de red al refrescar el token. Mostramos el panel igual.
              return _panelPorRol(cached.rol);
            },
          );
        }

        // ── CASO: hay sesión activa ──
        return FutureBuilder<String?>(
          future: _getRol(session.user.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _Cargando();
            }
            final rol = snap.data;
            if (rol == null) {
              return const LoginScreen();
            }
            return _panelPorRol(rol);
          },
        );
      },
    );
  }

  Widget _panelPorRol(String rol) {
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
  }

Future<String?> _getRol(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final data = await Supabase.instance.client
        .from('usuarios')
        .select('rol')
        .eq('id', userId)
        .single()
        .timeout(const Duration(seconds: 5));

    final rol = data['rol'] as String;
    await prefs.setString('rol_usuario', rol);
    await prefs.setString('usuario_id', userId);
    return rol;
  } catch (_) {
    // Sin red → usar caché local
    final rolLocal = prefs.getString('rol_usuario');
    final idLocal = prefs.getString('usuario_id');
    if (rolLocal != null && (idLocal == null || idLocal == userId)) {
      return rolLocal;
    }
    return null;
  }
}

  Future<_CachedAuth?> _getCachedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final rolLocal = prefs.getString('rol_usuario');
    final idLocal = prefs.getString('usuario_id');
    if (rolLocal == null || idLocal == null) return null;
    return _CachedAuth(rol: rolLocal, userId: idLocal);
  }
}

class _CachedAuth {
  final String rol;
  final String userId;
  _CachedAuth({required this.rol, required this.userId});
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