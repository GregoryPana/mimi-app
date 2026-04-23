import 'package:flutter_test/flutter_test.dart';
import 'package:mimi_app/main.dart';

void main() {
  testWidgets('App shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MimiApp());
    expect(find.text('Our Love Story'), findsOneWidget);
  });
}
