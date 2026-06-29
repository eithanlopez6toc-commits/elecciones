// lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_providers.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/recinto_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/acta_model.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/acta.dart';

const _kRecintosKey = 'cache_cp_recintos';
const _kCoordinadoresKey = 'cache_cp_coordinadores';
const _kActasRecintoPrefix = 'cache_cp_actas_recinto_';
const _kMesasRecintoPrefix = 'cache_cp_mesas_recinto_';
const _kTotalMesasKey = 'cache_cp_total_mesas';
const _kActasGlobalKey = 'cache_cp_actas_global';
const _kDashboardVotosKey = 'cache_cp_dashboard_votos';

// ─── Todos los recintos — con caché offline ──────────────────────────────────
final todosLosRecintosProvider = FutureProvider<List<Recinto>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final res = await supabase
        .from(SupabaseConstants.recintosTable)
        .select()
        .order('nombre')
        .timeout(const Duration(seconds: 6));

    final recintos = (res as List)
        .map((r) => RecintoModel.fromMap(r as Map<String, dynamic>))
        .toList();

    await prefs.setString(_kRecintosKey,
        jsonEncode(recintos.map((r) => RecintoModel.toMap(r)).toList()));
    return recintos;
  } catch (_) {
    final cached = prefs.getString(_kRecintosKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((r) => RecintoModel.fromMap(r as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// ─── Resumen de avance por recinto (sin caché propio: depende de red) ───────
class ResumenRecintoProv {
  final Recinto recinto;
  final int totalMesas;
  final int actasAlcalde;
  final int actasPrefecto;

  const ResumenRecintoProv({
    required this.recinto,
    required this.totalMesas,
    required this.actasAlcalde,
    required this.actasPrefecto,
  });

  int get totalActas => actasAlcalde + actasPrefecto;
  int get pendientes => (totalMesas * 2) - totalActas;
  double get porcentaje => totalMesas == 0 ? 0 : totalActas / (totalMesas * 2);
}

final resumenPorRecintoProvider =
    FutureProvider.family<ResumenRecintoProv, Recinto>((ref, recinto) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cache_cp_resumen_${recinto.id}';

  try {
    final mesasRes = await supabase
        .from(SupabaseConstants.mesasJrvTable)
        .select('id')
        .eq('recinto_id', recinto.id)
        .timeout(const Duration(seconds: 6));
    final mesaIds = (mesasRes as List).map((r) => r['id'] as int).toList();

    if (mesaIds.isEmpty) {
      final vacio = ResumenRecintoProv(
        recinto: recinto,
        totalMesas: 0,
        actasAlcalde: 0,
        actasPrefecto: 0,
      );
      return vacio;
    }

    final actasRes = await supabase
        .from(SupabaseConstants.actasTable)
        .select('dignidad')
        .inFilter('mesa_id', mesaIds)
        .timeout(const Duration(seconds: 6));

    int alcalde = 0, prefecto = 0;
    for (final row in actasRes as List) {
      final d = row['dignidad'] as String?;
      if (d == 'Alcalde') alcalde++;
      if (d == 'Prefecto') prefecto++;
    }

    final resumen = ResumenRecintoProv(
      recinto: recinto,
      totalMesas: mesaIds.length,
      actasAlcalde: alcalde,
      actasPrefecto: prefecto,
    );

    await prefs.setString(
        cacheKey,
        jsonEncode({
          'total_mesas': resumen.totalMesas,
          'actas_alcalde': resumen.actasAlcalde,
          'actas_prefecto': resumen.actasPrefecto,
        }));

    return resumen;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final m = jsonDecode(cached) as Map<String, dynamic>;
      return ResumenRecintoProv(
        recinto: recinto,
        totalMesas: m['total_mesas'] as int,
        actasAlcalde: m['actas_alcalde'] as int,
        actasPrefecto: m['actas_prefecto'] as int,
      );
    }
    return ResumenRecintoProv(
      recinto: recinto,
      totalMesas: 0,
      actasAlcalde: 0,
      actasPrefecto: 0,
    );
  }
});

// ─── Detalle de actas de un recinto (con GPS) — con caché offline ───────────
final actasDeRecintoProvider =
    FutureProvider.family<List<Acta>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kActasRecintoPrefix$recintoId';

  try {
    final mesasRes = await supabase
        .from(SupabaseConstants.mesasJrvTable)
        .select('id')
        .eq('recinto_id', recintoId)
        .timeout(const Duration(seconds: 6));
    final mesaIds = (mesasRes as List).map((r) => r['id'] as int).toList();
    if (mesaIds.isEmpty) {
      await prefs.setString(cacheKey, jsonEncode([]));
      return [];
    }

    final res = await supabase
        .from(SupabaseConstants.actasTable)
        .select()
        .inFilter('mesa_id', mesaIds)
        .order('created_at', ascending: false)
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

// ─── Mesas de un recinto — con caché offline ─────────────────────────────────
final mesasDeRecintoProvProv =
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

// ─── Mesas + progreso de actas (combina las dos anteriores, ya offline) ────
class MesaConProgreso {
  final MesaJrv mesa;
  final List<Acta> actas;

  const MesaConProgreso({required this.mesa, required this.actas});

  int get totalRegistradas => actas.length;
  double get porcentaje => totalRegistradas / 2;

  bool get tieneAlcalde => actas.any((a) => a.dignidad == Dignidad.alcalde);
  bool get tienePrefecto => actas.any((a) => a.dignidad == Dignidad.prefecto);

  Acta? get actaAlcalde {
    for (final a in actas) {
      if (a.dignidad == Dignidad.alcalde) return a;
    }
    return null;
  }

  Acta? get actaPrefecto {
    for (final a in actas) {
      if (a.dignidad == Dignidad.prefecto) return a;
    }
    return null;
  }

  Acta? get actaConGps {
    for (final a in actas) {
      if (a.gpsLat != null && a.gpsLng != null) return a;
    }
    return null;
  }
}

final mesasConProgresoProvider =
    FutureProvider.family<List<MesaConProgreso>, int>((ref, recintoId) async {
  // Ya heredan el comportamiento offline de los providers anteriores.
  final mesas = await ref.watch(mesasDeRecintoProvProv(recintoId).future);
  final actas = await ref.watch(actasDeRecintoProvider(recintoId).future);

  return mesas.map((mesa) {
    final actasDeMesa = actas.where((a) => a.mesaId == mesa.id).toList();
    return MesaConProgreso(mesa: mesa, actas: actasDeMesa);
  }).toList();
});

// ─── Total REAL de mesas/JRV registradas — con caché offline ───────────────
final totalMesasGlobalProvider = FutureProvider<int>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final res = await supabase
        .from(SupabaseConstants.mesasJrvTable)
        .select('id')
        .timeout(const Duration(seconds: 6));
    final total = (res as List).length;
    await prefs.setInt(_kTotalMesasKey, total);
    return total;
  } catch (_) {
    return prefs.getInt(_kTotalMesasKey) ?? 0;
  }
});

// ─── Dashboard: votos consolidados por candidato — con caché offline ───────
class VotosCandidato {
  final int candidatoId;
  final String nombre;
  final String dignidad;
  final String organizacion;
  final int totalVotos;
  final String? recintoNombre;

  const VotosCandidato({
    required this.candidatoId,
    required this.nombre,
    required this.dignidad,
    required this.organizacion,
    required this.totalVotos,
    this.recintoNombre,
  });

  Map<String, dynamic> toMap() => {
        'candidato_id': candidatoId,
        'nombre': nombre,
        'dignidad': dignidad,
        'organizacion': organizacion,
        'total_votos': totalVotos,
        'recinto_nombre': recintoNombre,
      };

  static VotosCandidato fromMap(Map<String, dynamic> m) => VotosCandidato(
        candidatoId: m['candidato_id'] as int,
        nombre: m['nombre'] as String,
        dignidad: m['dignidad'] as String,
        organizacion: m['organizacion'] as String,
        totalVotos: m['total_votos'] as int,
        recintoNombre: m['recinto_nombre'] as String?,
      );
}

final dashboardVotosProvider =
    FutureProvider<List<VotosCandidato>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final res = await supabase.from('votos_candidatos').select('''
      candidato_id,
      cantidad_votos,
      candidatos!inner(
        nombre,
        dignidad,
        organizaciones_politicas!inner(nombre)
      )
    ''').timeout(const Duration(seconds: 6));

    final Map<int, VotosCandidato> mapa = {};
    for (final row in res as List) {
      final cid = row['candidato_id'] as int;
      final votos = row['cantidad_votos'] as int;
      final cand = row['candidatos'] as Map<String, dynamic>;
      final org = cand['organizaciones_politicas'] as Map<String, dynamic>;

      if (mapa.containsKey(cid)) {
        mapa[cid] = VotosCandidato(
          candidatoId: cid,
          nombre: mapa[cid]!.nombre,
          dignidad: mapa[cid]!.dignidad,
          organizacion: mapa[cid]!.organizacion,
          totalVotos: mapa[cid]!.totalVotos + votos,
        );
      } else {
        mapa[cid] = VotosCandidato(
          candidatoId: cid,
          nombre: cand['nombre'] as String,
          dignidad: cand['dignidad'] as String,
          organizacion: org['nombre'] as String,
          totalVotos: votos,
        );
      }
    }

    final lista = mapa.values.toList()
      ..sort((a, b) => b.totalVotos.compareTo(a.totalVotos));

    await prefs.setString(
        _kDashboardVotosKey, jsonEncode(lista.map((v) => v.toMap()).toList()));
    return lista;
  } catch (_) {
    final cached = prefs.getString(_kDashboardVotosKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((m) => VotosCandidato.fromMap(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// ─── Crear recinto (requiere red, sin caché) ─────────────────────────────────
final crearRecintoProvider = Provider<
    Future<Recinto> Function(
      String canton,
      String parroquia,
      String nombre,
      String? direccion,
      int numJrv,
    )>((ref) {
  return (canton, parroquia, nombre, direccion, numJrv) async {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from(SupabaseConstants.recintosTable)
        .insert({
          'canton': canton,
          'parroquia': parroquia,
          'nombre': nombre,
          'provincia': 'Ecuador',
          'num_jrv': numJrv,
          if (direccion != null) 'direccion': direccion,
        })
        .select()
        .single();
    final recinto = RecintoModel.fromMap(res);

    if (numJrv > 0) {
      final mesasParaInsertar = List.generate(
        numJrv,
        (i) => {
          'recinto_id': recinto.id,
          'numero_mesa': i + 1,
        },
      );
      await supabase
          .from(SupabaseConstants.mesasJrvTable)
          .insert(mesasParaInsertar);
    }

    return recinto;
  };
});

// ─── Crear coordinador de recinto (requiere red, sin caché) ────────────────
final crearCoordinadorRecintoProvider = Provider<
    Future<void> Function(
      String cedula,
      String nombre,
      String apellido,
      String telefono,
      String correo,
      int recintoId,
    )>((ref) {
  return (cedula, nombre, apellido, telefono, correo, recintoId) async {
    final supabase = ref.read(supabaseClientProvider);

    final response = await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'correo': correo,
      'rol': 'coordinador_recinto',
      'recinto_id': recintoId,
    });

    if (response.status != 200) {
      final mensaje = response.data?['error'] ??
          response.data?['message'] ??
          'Error desconocido (status ${response.status})';
      throw Exception(mensaje);
    }
  };
});

// ─── Coordinadores de recinto — con caché offline ───────────────────────────
final coordinadoresRecintoProvider = FutureProvider<List<Usuario>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final res = await supabase
        .from('usuarios')
        .select()
        .eq('rol', 'coordinador_recinto')
        .order('nombre')
        .timeout(const Duration(seconds: 6));

    final usuarios = (res as List)
        .map((r) => UsuarioModel.fromMap(r as Map<String, dynamic>, correo: ''))
        .toList();

    await prefs.setString(_kCoordinadoresKey,
        jsonEncode(usuarios.map((u) => UsuarioModel.toMap(u)).toList()));
    return usuarios;
  } catch (_) {
    final cached = prefs.getString(_kCoordinadoresKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((m) =>
              UsuarioModel.fromMap(m as Map<String, dynamic>, correo: ''))
          .toList();
    }
    return [];
  }
});

// ─── Conteo global de actas ingresadas — con caché offline ──────────────────
final actasGlobalCountProvider = FutureProvider<int>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();

  try {
    final res = await supabase
        .from(SupabaseConstants.actasTable)
        .select('id')
        .timeout(const Duration(seconds: 6));
    final total = (res as List).length;
    await prefs.setInt(_kActasGlobalKey, total);
    return total;
  } catch (_) {
    return prefs.getInt(_kActasGlobalKey) ?? 0;
  }
});

// ─── Eliminar coordinador (requiere red, sin caché) ─────────────────────────
final eliminarCoordinadorProvider =
    Provider<Future<void> Function(String userId)>((ref) {
  return (userId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from('usuarios').delete().eq('id', userId);
    await supabase.functions
        .invoke('eliminar-usuario', body: {'user_id': userId});
  };
});
