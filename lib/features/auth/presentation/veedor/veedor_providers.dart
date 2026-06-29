// lib/features/auth/presentation/veedor/veedor_providers.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../data/datasources/supabase_client_provider.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/acta_model.dart';
import '../../data/models/organizacion_politica_model.dart';
import '../../data/repositories/acta_repository_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Claves SharedPreferences para caché offline
// ─────────────────────────────────────────────────────────────────────────────
const _kMesasPrefix = 'cache_mesas_';
const _kActasPrefix = 'cache_actas_';
const _kOrgsPrefix = 'cache_orgs_';

// ─────────────────────────────────────────────────────────────────────────────
// Mesas asignadas al veedor — con caché offline
// ─────────────────────────────────────────────────────────────────────────────
final mesasVeedorProvider =
    FutureProvider.family<List<MesaJrv>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kMesasPrefix$usuarioId';

  try {
    final resultado = await supabase
        .from('veedor_mesas')
        .select('mesa_id, mesas_jrv(*)')
        .eq('usuario_id', usuarioId)
        .timeout(const Duration(seconds: 6));

    final mesas = (resultado as List)
        .map((row) =>
            MesaJrvModel.fromMap(row['mesas_jrv'] as Map<String, dynamic>))
        .toList();

    final encoded =
        jsonEncode(mesas.map((m) => MesaJrvModel.toMap(m)).toList());
    await prefs.setString(cacheKey, encoded);

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

// ─────────────────────────────────────────────────────────────────────────────
// Actas del veedor — con caché offline + actas locales pendientes
// ─────────────────────────────────────────────────────────────────────────────
final actasVeedorProvider =
    FutureProvider.family<List<Acta>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = '$_kActasPrefix$usuarioId';

  List<Acta> actasRemotas = [];

  try {
    final resultado = await supabase
        .from('actas')
        .select()
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false)
        .timeout(const Duration(seconds: 6));

    actasRemotas = (resultado as List)
        .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
        .toList();

    final encoded =
        jsonEncode(actasRemotas.map((a) => ActaModel.toMap(a)).toList());
    await prefs.setString(cacheKey, encoded);
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      actasRemotas = list
          .map((m) => ActaModel.fromMap(m as Map<String, dynamic>))
          .toList();
    }
  }

  // Fusionar con actas locales pendientes de sync (SQLite)
  final actasLocales = await _leerActasLocalesPendientes(usuarioId);

  // Las locales "ganan" sobre las remotas para la misma mesa+dignidad
  final Map<String, Acta> mapa = {
    for (final a in actasRemotas) '${a.mesaId}_${a.dignidad?.name}': a,
  };
  for (final local in actasLocales) {
    mapa['${local.mesaId}_${local.dignidad?.name}'] = local;
  }

  return mapa.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Lee actas pendientes de SQLite y las devuelve como [Acta] con pendienteSync=true
Future<List<Acta>> _leerActasLocalesPendientes(String usuarioId) async {
  try {
    final dbPath = p.join(await getDatabasesPath(), 'actas_pendientes.db');
    final db = await openDatabase(dbPath, version: 1);
    final rows = await db.query(
      'actas_pendientes',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return rows.map((row) {
      final votosJson = row['votos_json'] as String? ?? '';
      final votos = votosJson.isEmpty
          ? <String, int>{}
          : Map.fromEntries(votosJson.split(',').map((e) {
              final parts = e.split(':');
              return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
            }));
      return Acta(
        id: -(row['id'] as int), // id negativo = local
        mesaId: row['mesa_id'] as int,
        usuarioId: row['usuario_id'] as String?,
        dignidad: row['dignidad'] != null
            ? Dignidad.values.byName(row['dignidad'] as String)
            : null,
        votosPorOrganizacion: votos,
        votosNulos: row['votos_nulos'] as int? ?? 0,
        votosBlancos: row['votos_blancos'] as int? ?? 0,
        totalSufragantes: row['total_sufragantes'] as int?,
        urlFotoActa: '',
        gpsLat: (row['gps_lat'] as num?)?.toDouble(),
        gpsLng: (row['gps_lng'] as num?)?.toDouble(),
        estado: EstadoActa.ingresada,
        createdAt: DateTime.parse(row['created_at'] as String),
        pendienteSync: true,
      );
    }).toList();
  } catch (_) {
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actas de una mesa específica — con caché offline + pendientes locales
// ─────────────────────────────────────────────────────────────────────────────
final actasPorMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cache_actas_mesa_$mesaId';

  List<Acta> actasRemotas = [];

  try {
    final resultado = await supabase
        .from('actas')
        .select()
        .eq('mesa_id', mesaId)
        .timeout(const Duration(seconds: 6));

    actasRemotas = (resultado as List)
        .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
        .toList();

    await prefs.setString(
        cacheKey, jsonEncode(actasRemotas.map(ActaModel.toMap).toList()));
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      actasRemotas = list
          .map((m) => ActaModel.fromMap(m as Map<String, dynamic>))
          .toList();
    }
  }

  final Map<String, Acta> mapa = {
    for (final a in actasRemotas) '${a.mesaId}_${a.dignidad?.name}': a,
  };
  try {
    final dbPath = p.join(await getDatabasesPath(), 'actas_pendientes.db');
    final db = await openDatabase(dbPath, version: 1);
    final rows = await db.query(
      'actas_pendientes',
      where: 'mesa_id = ?',
      whereArgs: [mesaId],
    );
    for (final row in rows) {
      final votosJson = row['votos_json'] as String? ?? '';
      final votos = votosJson.isEmpty
          ? <String, int>{}
          : Map.fromEntries(votosJson.split(',').map((e) {
              final parts = e.split(':');
              return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
            }));
      final local = Acta(
        id: -(row['id'] as int),
        mesaId: row['mesa_id'] as int,
        usuarioId: row['usuario_id'] as String?,
        dignidad: row['dignidad'] != null
            ? Dignidad.values.byName(row['dignidad'] as String)
            : null,
        votosPorOrganizacion: votos,
        votosNulos: row['votos_nulos'] as int? ?? 0,
        votosBlancos: row['votos_blancos'] as int? ?? 0,
        totalSufragantes: row['total_sufragantes'] as int?,
        urlFotoActa: '',
        gpsLat: (row['gps_lat'] as num?)?.toDouble(),
        gpsLng: (row['gps_lng'] as num?)?.toDouble(),
        estado: EstadoActa.ingresada,
        createdAt: DateTime.parse(row['created_at'] as String),
        pendienteSync: true,
      );
      mapa['${local.mesaId}_${local.dignidad?.name}'] = local;
    }
  } catch (_) {}

  return mapa.values.toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Organizaciones por dignidad — con caché offline
// ─────────────────────────────────────────────────────────────────────────────
final organizacionesPorDignidadProvider =
    FutureProvider.family<List<OrganizacionPolitica>, Dignidad>(
        (ref, dignidad) async {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final dbValue = _dignidadToDb(dignidad);
  final cacheKey = '$_kOrgsPrefix$dbValue';

  try {
    final resultado = await supabase.from('candidatos').select('''
        nombre,
        dignidad,
        organizaciones_politicas(id, nombre, lista_numero)
      ''').eq('dignidad', dbValue).timeout(const Duration(seconds: 6));

    final orgs = (resultado as List).map((row) {
      final org = row['organizaciones_politicas'] as Map<String, dynamic>;
      return OrganizacionPoliticaModel.fromMap({
        'id': org['id'],
        'nombre': org['nombre'],
        'lista_numero': org['lista_numero'],
        'candidato_nombre': row['nombre'] as String,
      });
    }).toList();

    orgs.sort((a, b) => a.listaNumero.compareTo(b.listaNumero));

    await prefs.setString(
        cacheKey, jsonEncode(orgs.map((o) => o.toMap()).toList()));

    return orgs;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((m) =>
              OrganizacionPoliticaModel.fromMap(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Mesas ocupadas por recinto
// ─────────────────────────────────────────────────────────────────────────────
final mesasOcupadasPorRecintoProvider =
    FutureProvider.family<Set<int>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  try {
    final resultado = await supabase
        .from('veedor_mesas')
        .select('mesa_id, mesas_jrv!inner(recinto_id)')
        .eq('mesas_jrv.recinto_id', recintoId)
        .timeout(const Duration(seconds: 6));
    return {
      for (final row in (resultado as List)) row['mesa_id'] as int,
    };
  } catch (_) {
    return {};
  }
});

String _dignidadToDb(Dignidad d) {
  switch (d) {
    case Dignidad.alcalde:
      return 'Alcalde';
    case Dignidad.prefecto:
      return 'Prefecto';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado del proceso de sync
// ─────────────────────────────────────────────────────────────────────────────
class SyncPendientesState {
  final bool sincronizando;
  final int pendientes;
  final int sincronizados;

  const SyncPendientesState({
    this.sincronizando = false,
    this.pendientes = 0,
    this.sincronizados = 0,
  });

  SyncPendientesState copyWith({
    bool? sincronizando,
    int? pendientes,
    int? sincronizados,
  }) =>
      SyncPendientesState(
        sincronizando: sincronizando ?? this.sincronizando,
        pendientes: pendientes ?? this.pendientes,
        sincronizados: sincronizados ?? this.sincronizados,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier de sync
// ─────────────────────────────────────────────────────────────────────────────
class SyncPendientesNotifier extends StateNotifier<SyncPendientesState> {
  final Ref _ref;
  SyncPendientesNotifier(this._ref) : super(const SyncPendientesState()) {
    // Contar pendientes al arrancar
    contarPendientes();
  }

  static Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'actas_pendientes.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS actas_pendientes (
          id            INTEGER PRIMARY KEY AUTOINCREMENT,
          mesa_id       INTEGER NOT NULL,
          usuario_id    TEXT,
          dignidad      TEXT,
          votos_json    TEXT,
          votos_nulos   INTEGER DEFAULT 0,
          votos_blancos INTEGER DEFAULT 0,
          total_sufragantes INTEGER,
          foto_path     TEXT,
          gps_lat       REAL,
          gps_lng       REAL,
          estado        TEXT DEFAULT 'INGRESADA',
          created_at    TEXT,
          intentos      INTEGER DEFAULT 0
        )
      ''');
    });
    return _db!;
  }

  // ★ FIX: ahora público para que el controller también lo llame
  Future<void> contarPendientes() async {
    try {
      final db = await _database;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM actas_pendientes'));
      if (mounted) state = state.copyWith(pendientes: count ?? 0);
    } catch (_) {}
  }

  Future<void> sincronizarTodos({required String userId}) async {
    if (state.sincronizando) return;

    // ★ FIX: resetear sincronizados en cada llamada para que
    //         ref.listen(prev.sincronizando → next.sincronizando) dispare siempre
    state = state.copyWith(sincronizando: true, sincronizados: 0);

    try {
      final db = await _database;
      final pendientes = await db.query(
        'actas_pendientes',
        where: 'usuario_id = ?',
        whereArgs: [userId],
        orderBy: 'id ASC',
      );

      if (pendientes.isEmpty) {
        if (mounted) state = state.copyWith(sincronizando: false, pendientes: 0);
        return;
      }

      final repo = _ref.read(actaRepositoryProvider);
      int sincronizados = 0;

      for (final row in pendientes) {
        try {
          final localId = row['id'] as int;
          final File? fotoFile = row['foto_path'] != null
              ? File(row['foto_path'] as String)
              : null;

          String fotoUrl = '';
          if (fotoFile != null && await fotoFile.exists()) {
            fotoUrl = await repo.subirFotoActa(fotoFile);
          }

          final votosJson = row['votos_json'] as String? ?? '';
          final votos = votosJson.isEmpty
              ? <String, int>{}
              : Map.fromEntries(votosJson.split(',').map((e) {
                  final parts = e.split(':');
                  return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
                }));

          final acta = Acta(
            id: 0,
            mesaId: row['mesa_id'] as int,
            usuarioId: row['usuario_id'] as String?,
            dignidad: row['dignidad'] != null
                ? Dignidad.values.byName(row['dignidad'] as String)
                : null,
            votosPorOrganizacion: votos,
            votosNulos: row['votos_nulos'] as int? ?? 0,
            votosBlancos: row['votos_blancos'] as int? ?? 0,
            totalSufragantes: row['total_sufragantes'] as int?,
            urlFotoActa: fotoUrl,
            gpsLat: (row['gps_lat'] as num?)?.toDouble(),
            gpsLng: (row['gps_lng'] as num?)?.toDouble(),
            estado: EstadoActa.ingresada,
            createdAt: DateTime.parse(row['created_at'] as String),
          );

          await repo.guardarActa(acta);
          await db.delete('actas_pendientes',
              where: 'id = ?', whereArgs: [localId]);
          sincronizados++;
        } catch (_) {
          await db.rawUpdate(
            'UPDATE actas_pendientes SET intentos = intentos + 1 WHERE id = ?',
            [row['id']],
          );
        }
      }

      final restantes = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM actas_pendientes'));

      if (mounted) {
        state = state.copyWith(
          sincronizando: false,
          pendientes: restantes ?? 0,
          sincronizados: sincronizados,
        );
      }
    } catch (_) {
      if (mounted) state = state.copyWith(sincronizando: false);
    }
  }
}

final syncPendientesProvider =
    StateNotifierProvider<SyncPendientesNotifier, SyncPendientesState>(
        (ref) => SyncPendientesNotifier(ref));