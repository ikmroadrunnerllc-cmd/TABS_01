// Basic smoke test for the Status Card Theme app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:status_card_app/main.dart';

void main() {
  testWidgets('Status card renders and theme switch toggles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RunMyApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Theme Lab'), findsOneWidget);
    expect(find.text('Status: Online'), findsOneWidget);

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    Switch switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isTrue);
  });
}
