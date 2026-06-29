// lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_providers.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/acta_model.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/acta.dart';

const _kMesasRecintoPrefix = 'cache_cr_mesas_';
const _kActasMesaPrefix = 'cache_cr_actas_mesa_';
const _kVeedoresPrefix = 'cache_cr_veedores_';
const _kResumenPrefix = 'cache_cr_resumen_';

// ─── Mesas del recinto — con caché offline ───────────────────────────────────
final mesasPorRecintoProvider =
    FutureProvider.family<List<MesaJrv>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kMesasRecintoPrefix$recintoId';

  try {
    final res = await supabase
        .from(SupabaseConstants.mesasJrvTable)
        .select()
        .eq('recinto_id', recintoId)
        .order('numero_mesa')
        .timeout(const Duration(seconds: 6));

    final mesas = (res as List)
        .map((r) => MesaJrvModel.fromMap(r as Map<String, dynamic>))
        .toList();

    await prefs.setString(
        cacheKey, jsonEncode(mesas.map((m) => MesaJrvModel.toMap(m)).toList()));
    return mesas;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((m) => MesaJrvModel.fromMap(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// ─── Actas de una mesa — con caché offline ───────────────────────────────────
final actasDeMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kActasMesaPrefix$mesaId';

  try {
    final res = await supabase
        .from(SupabaseConstants.actasTable)
        .select()
        .eq('mesa_id', mesaId)
        .timeout(const Duration(seconds: 6));

    final actas = (res as List)
        .map((r) => ActaModel.fromMap(r as Map<String, dynamic>))
        .toList();

    await prefs.setString(
        cacheKey, jsonEncode(actas.map((a) => ActaModel.toMap(a)).toList()));
    return actas;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((m) => ActaModel.fromMap(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// ─── Veedor + info de mesa asignada ──────────────────────────────────────────
class VeedorConMesa {
  final Usuario usuario;
  final int? mesaId;
  final int? numeroMesa;
  final bool reasignado;

  const VeedorConMesa({
    required this.usuario,
    this.mesaId,
    this.numeroMesa,
    this.reasignado = false,
  });

  bool get disponible => mesaId == null;

  Map<String, dynamic> toMap() => {
        'usuario': UsuarioModel.toMap(usuario),
        'correo': usuario.correo,
        'mesa_id': mesaId,
        'numero_mesa': numeroMesa,
        'reasignado': reasignado,
      };

  static VeedorConMesa fromMap(Map<String, dynamic> m) => VeedorConMesa(
        usuario: UsuarioModel.fromMap(
          m['usuario'] as Map<String, dynamic>,
          correo: m['correo'] as String? ?? '',
        ),
        mesaId: m['mesa_id'] as int?,
        numeroMesa: m['numero_mesa'] as int?,
        reasignado: m['reasignado'] as bool? ?? false,
      );
}

// ─── Veedores del recinto — con caché offline ────────────────────────────────
final veedoresDeRecintoProvider =
    FutureProvider.family<List<VeedorConMesa>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kVeedoresPrefix$recintoId';

  try {
    final res = await supabase
        .from('veedor_mesas')
        .select('''
          usuario_id,
          mesa_id,
          usuarios!inner(*),
          mesas_jrv!inner(recinto_id, numero_mesa)
        ''')
        .eq('mesas_jrv.recinto_id', recintoId)
        .timeout(const Duration(seconds: 6));

    final vistos = <String>{};
    final lista = <VeedorConMesa>[];
    for (final row in res as List) {
      final uid = row['usuario_id'] as String;
      if (!vistos.contains(uid)) {
        vistos.add(uid);
        final mesaJrv = row['mesas_jrv'] as Map<String, dynamic>?;
        lista.add(VeedorConMesa(
          usuario: UsuarioModel.fromMap(
            row['usuarios'] as Map<String, dynamic>,
            correo: '',
          ),
          mesaId: row['mesa_id'] as int?,
          numeroMesa: mesaJrv?['numero_mesa'] as int?,
        ));
      }
    }

    lista.sort((a, b) {
      if (a.disponible == b.disponible) return 0;
      return a.disponible ? -1 : 1;
    });

    await prefs.setString(
        cacheKey, jsonEncode(lista.map((v) => v.toMap()).toList()));
    return lista;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((m) => VeedorConMesa.fromMap(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// ─── Resumen de avance del recinto — con caché offline ───────────────────────
class ResumenRecinto {
  final int totalMesas;
  final int mesasConActaAlcalde;
  final int mesasConActaPrefecto;

  const ResumenRecinto({
    required this.totalMesas,
    required this.mesasConActaAlcalde,
    required this.mesasConActaPrefecto,
  });

  int get mesasCompletas => [mesasConActaAlcalde, mesasConActaPrefecto]
      .reduce((a, b) => a < b ? a : b);
  int get actasPendientes =>
      (totalMesas * 2) - mesasConActaAlcalde - mesasConActaPrefecto;

  Map<String, dynamic> toMap() => {
        'total_mesas': totalMesas,
        'actas_alcalde': mesasConActaAlcalde,
        'actas_prefecto': mesasConActaPrefecto,
      };

  static ResumenRecinto fromMap(Map<String, dynamic> m) => ResumenRecinto(
        totalMesas: m['total_mesas'] as int,
        mesasConActaAlcalde: m['actas_alcalde'] as int,
        mesasConActaPrefecto: m['actas_prefecto'] as int,
      );
}

final resumenRecintoProvider =
    FutureProvider.family<ResumenRecinto, int>((ref, recintoId) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kResumenPrefix$recintoId';

  try {
    final mesas = await ref.watch(mesasPorRecintoProvider(recintoId).future);
    if (mesas.isEmpty) {
      const vacio = ResumenRecinto(
          totalMesas: 0, mesasConActaAlcalde: 0, mesasConActaPrefecto: 0);
      return vacio;
    }

    final supabase = ref.watch(supabaseClientProvider);
    final mesaIds = mesas.map((m) => m.id).toList();

    final res = await supabase
        .from(SupabaseConstants.actasTable)
        .select('mesa_id, dignidad')
        .inFilter('mesa_id', mesaIds)
        .timeout(const Duration(seconds: 6));

    int alcalde = 0, prefecto = 0;
    for (final row in res as List) {
      final d = row['dignidad'] as String?;
      if (d == 'Alcalde') alcalde++;
      if (d == 'Prefecto') prefecto++;
    }

    final resumen = ResumenRecinto(
      totalMesas: mesas.length,
      mesasConActaAlcalde: alcalde,
      mesasConActaPrefecto: prefecto,
    );

    await prefs.setString(cacheKey, jsonEncode(resumen.toMap()));
    return resumen;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      return ResumenRecinto.fromMap(jsonDecode(cached) as Map<String, dynamic>);
    }
    return const ResumenRecinto(
        totalMesas: 0, mesasConActaAlcalde: 0, mesasConActaPrefecto: 0);
  }
});

// ─── Crear cuenta de veedor (requiere red, sin cache) ────────────────────────
final crearVeedorProvider = Provider<
    Future<void> Function(String cedula, String nombre, String apellido,
        String telefono, String correo, int mesaId)>((ref) {
  return (cedula, nombre, apellido, telefono, correo, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    final response = await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
      'rol': 'veedor',
      'mesa_id': mesaId,
    });

    if (response.status != 200) {
      final mensaje = response.data?['error'] ??
          response.data?['message'] ??
          'Error desconocido (status ${response.status})';
      throw Exception(mensaje);
    }
  };
});

// ─── Editar/corregir acta (requiere red, sin cache) ──────────────────────────
final editarActaProvider = Provider<
    Future<void> Function({
      required int actaId,
      required Map<String, dynamic> campos,
    })>((ref) {
  return ({required actaId, required campos}) async {
    final supabase = ref.read(supabaseClientProvider);
    final updates = {
      ...campos,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase
        .from(SupabaseConstants.actasTable)
        .update(updates)
        .eq('id', actaId);
  };
});

// ─── Reasignar veedor a mesa ──────────────────────────────────────────────────
final reasignarVeedorProvider =
    Provider<Future<void> Function(String usuarioId, int mesaId)>((ref) {
  return (usuarioId, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('veedor_mesas').delete().eq('usuario_id', usuarioId);
    await supabase.from('veedor_mesas').insert({
      'usuario_id': usuarioId,
      'mesa_id': mesaId,
    });
  };
});

// ─── Liberar veedor (queda disponible, sin mesa) ─────────────────────────────
final liberarVeedorProvider =
    Provider<Future<void> Function(String usuarioId)>((ref) {
  return (usuarioId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase
        .from('veedor_mesas')
        .update({'mesa_id': null}).eq('usuario_id', usuarioId);
  };
});

// ─── Eliminar veedor del recinto ─────────────────────────────────────────────
final eliminarVeedorProvider =
    Provider<Future<void> Function(String usuarioId)>((ref) {
  return (usuarioId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('veedor_mesas').delete().eq('usuario_id', usuarioId);
  };
});
