// lib/features/auth/data/datasources/usuario_cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/usuario.dart';
import '../models/usuario_model.dart';

class UsuarioCacheService {
  static const _key = 'usuario_cache';

  static Future<void> guardar(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, UsuarioModel.toJson(usuario));
  }

  static Future<Usuario?> leer() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return UsuarioModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}