// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:elecciones/main.dart';

void main() {
  testWidgets('App muestra la pantalla de login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ControlElectoralApp());

    // Verify that the login placeholder text is shown.
    expect(find.text('Pantalla de login — siguiente paso'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
