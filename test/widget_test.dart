import 'package:flutter_test/flutter_test.dart';
import 'package:magnusfly/main.dart';

void main() {
  testWidgets('shows the app name', (tester) async {
    await tester.pumpWidget(const MagnusFlyApp());

    expect(find.text('MagnusFly'), findsOneWidget);
  });
}
