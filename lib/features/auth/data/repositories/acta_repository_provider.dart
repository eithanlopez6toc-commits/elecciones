// lib/features/auth/data/repositories/acta_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/supabase_client_provider.dart';
import '../../domain/repositories/acta_repository.dart';
import '../../domain/usecases/registrar_acta_usecase.dart';
import 'acta_repository_impl.dart';

final actaRepositoryProvider = Provider<ActaRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ActaRepositoryImpl(supabase);
});

final registrarActaUseCaseProvider = Provider<RegistrarActaUseCase>((ref) {
  return RegistrarActaUseCase(ref.watch(actaRepositoryProvider));
});