import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows localized home screen and changes language',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'pilot_profile.username': 'testpilot',
      'pilot_profile.name': 'Test Pilot',
      'pilot_profile.email': 'testpilot@example.com',
      'pilot_profile.country': 'BR',
    });

    await tester.pumpWidget(const MagnusFlyApp());
    await tester.pumpAndSettle();

    expect(find.text('MagnusFly'), findsOneWidget);
    expect(find.text('Start as Driver'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Portuguese'));
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsOneWidget);

    Navigator.of(tester.element(find.text('Configurações'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Iniciar como Motorista'), findsOneWidget);
  });
}
