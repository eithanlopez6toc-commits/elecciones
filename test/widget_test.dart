import 'package:flutter_test/flutter_test.dart';

import 'package:elecciones/main.dart';

void main() {
  testWidgets('App muestra la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const ControlElectoralApp());

    expect(find.text('Acceda a su portal de votación'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
