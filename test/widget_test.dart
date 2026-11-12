import 'package:flutter_test/flutter_test.dart';
import 'package:spendsmart/main.dart';

void main() {
  testWidgets('SpendSmart app smoke test', (WidgetTester tester) async {
    // Build SpendSmartApp and trigger a frame.
    await tester.pumpWidget(const SpendSmartApp());
    expect(find.text('SpendSmart'), findsOneWidget);
  });
}
