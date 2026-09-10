import 'package:flutter_test/flutter_test.dart';

import 'package:in_class_01_tabs/main.dart';

void main() {
  testWidgets('All 4 tabs render and can be switched', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Tab 1'), findsWidgets);
    expect(find.text('Tab 2'), findsWidgets);
    expect(find.text('Tab 3'), findsWidgets);
    expect(find.text('Tab 4'), findsWidgets);

    await tester.tap(find.text('Tab 3').last);
    await tester.pumpAndSettle();
    expect(find.text('Click me'), findsOneWidget);
  });
}
