// lib/features/auth/data/repositories/auth_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/supabase_client_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabase);
});