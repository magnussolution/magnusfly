import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/main.dart';

void main() {
  testWidgets('shows localized home screen and changes language',
      (tester) async {
    await tester.pumpWidget(const MagnusFlyApp());

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
