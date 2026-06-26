import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/auth/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: ControlElectoralApp()));
}

class ControlElectoralApp extends StatelessWidget {
  const ControlElectoralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Electoral',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const LoginScreen(),
    );
  }
}