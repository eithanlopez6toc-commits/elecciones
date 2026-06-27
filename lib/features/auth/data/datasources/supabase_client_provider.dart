import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client; // mismo cliente inicializado en main.dart
});

final supabaseAuthProvider =
    Provider<GoTrueClient>((ref) => ref.watch(supabaseClientProvider).auth);

final supabaseStorageProvider = Provider<SupabaseStorageClient>(
  (ref) => ref.watch(supabaseClientProvider).storage,
);