// lib/features/auth/presentation/veedor/veedor_providers.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
// Mesas asignadas al veedor
// ─────────────────────────────────────────────────────────────────────────────
final mesasVeedorProvider =
    FutureProvider.family<List<MesaJrv>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final resultado = await supabase
      .from('veedor_mesas')
      .select('mesa_id, mesas_jrv(*)')
      .eq('usuario_id', usuarioId);
  return (resultado as List)
      .map((row) =>
          MesaJrvModel.fromMap(row['mesas_jrv'] as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Actas registradas por el veedor
// ─────────────────────────────────────────────────────────────────────────────
final actasVeedorProvider =
    FutureProvider.family<List<Acta>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final resultado = await supabase
      .from('actas')
      .select()
      .eq('usuario_id', usuarioId)
      .order('created_at', ascending: false);
  return (resultado as List)
      .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Actas de una mesa específica
// ─────────────────────────────────────────────────────────────────────────────
final actasPorMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final resultado = await supabase.from('actas').select().eq('mesa_id', mesaId);
  return (resultado as List)
      .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Organizaciones con el candidato de la dignidad seleccionada
//
// FIX: Se hace en 2 pasos para evitar el problema con .order() en columnas
// de tablas relacionadas, que Supabase no soporta en PostgREST básico.
//
// Paso 1: traer candidatos de esa dignidad con su organización
// Paso 2: ordenar por lista_numero en Dart
// ─────────────────────────────────────────────────────────────────────────────
final organizacionesPorDignidadProvider =
    FutureProvider.family<List<OrganizacionPolitica>, Dignidad>(
        (ref, dignidad) async {
  final supabase = ref.watch(supabaseClientProvider);
  final dbValue = _dignidadToDb(dignidad);

  final resultado = await supabase.from('candidatos').select('''
        nombre,
        dignidad,
        organizaciones_politicas(id, nombre, lista_numero)
      ''').eq('dignidad', dbValue);

  final orgs = (resultado as List).map((row) {
    final org = row['organizaciones_politicas'] as Map<String, dynamic>;
    return OrganizacionPoliticaModel.fromMap({
      'id': org['id'],
      'nombre': org['nombre'],
      'lista_numero': org['lista_numero'],
      'candidato_nombre': row['nombre'] as String,
    });
  }).toList();

  // Ordenar por lista_numero en Dart (evita el bug de .order() con FK)
  orgs.sort((a, b) => a.listaNumero.compareTo(b.listaNumero));

  return orgs;
});

// ─────────────────────────────────────────────────────────────────────────────
// IDs de mesas ocupadas para un recinto
// ─────────────────────────────────────────────────────────────────────────────
final mesasOcupadasPorRecintoProvider =
    FutureProvider.family<Set<int>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final resultado = await supabase
      .from('veedor_mesas')
      .select('mesa_id, mesas_jrv!inner(recinto_id)')
      .eq('mesas_jrv.recinto_id', recintoId);
  return {
    for (final row in (resultado as List)) row['mesa_id'] as int,
  };
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
// Sync de actas pendientes (offline → servidor)
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
  }) {
    return SyncPendientesState(
      sincronizando: sincronizando ?? this.sincronizando,
      pendientes: pendientes ?? this.pendientes,
      sincronizados: sincronizados ?? this.sincronizados,
    );
  }
}

class SyncPendientesNotifier extends StateNotifier<SyncPendientesState> {
  final Ref _ref;

  SyncPendientesNotifier(this._ref) : super(const SyncPendientesState());

  static Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'actas_pendientes.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS actas_pendientes (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            mesa_id      INTEGER NOT NULL,
            usuario_id   TEXT,
            dignidad     TEXT,
            votos_json   TEXT,
            votos_nulos  INTEGER DEFAULT 0,
            votos_blancos INTEGER DEFAULT 0,
            total_sufragantes INTEGER,
            foto_path    TEXT,
            gps_lat      REAL,
            gps_lng      REAL,
            estado       TEXT DEFAULT 'INGRESADA',
            created_at   TEXT,
            intentos     INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> contarPendientes() async {
    try {
      final db = await _database;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM actas_pendientes'));
      state = state.copyWith(pendientes: count ?? 0);
    } catch (_) {
      state = state.copyWith(pendientes: 0);
    }
  }

  Future<void> sincronizarTodos({required String userId}) async {
    if (state.sincronizando) return;
    state = state.copyWith(sincronizando: true);

    try {
      final db = await _database;
      final pendientes = await db.query('actas_pendientes', orderBy: 'id ASC');

      if (pendientes.isEmpty) {
        state = state.copyWith(sincronizando: false, pendientes: 0);
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
            votosNulos: row['votos_nulos'] as int,
            votosBlancos: row['votos_blancos'] as int,
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

      state = state.copyWith(
        sincronizando: false,
        pendientes: restantes ?? 0,
        sincronizados: state.sincronizados + sincronizados,
      );
    } catch (e) {
      state = state.copyWith(sincronizando: false);
    }
  }
}

final syncPendientesProvider =
    StateNotifierProvider<SyncPendientesNotifier, SyncPendientesState>((ref) {
  return SyncPendientesNotifier(ref);
});
