import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> tapKeys(WidgetTester tester, String keys) async {
    for (final k in keys.split(' ')) {
      await tester.tap(find.byKey(Key('key-$k')));
      await tester.pump();
    }
  }

  String display(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('display'))).data!;

  testWidgets('2 + 3 × 4 = shows running total then 20', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(display(tester), '0');

    await tapKeys(tester, '2 + 3 ×');
    expect(display(tester), '5');
    expect(find.text('5 ×'), findsOneWidget);

    await tapKeys(tester, '4 =');
    expect(display(tester), '20');
  });

  testWidgets('divide by zero shows error, AC recovers', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tapKeys(tester, '8 ÷ 0 =');
    expect(display(tester), 'Error');
    expect(find.text('Cannot divide by zero'), findsOneWidget);

    await tapKeys(tester, 'AC');
    expect(display(tester), '0');
  });

  testWidgets('fits a small phone screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalculatorApp());
    await tapKeys(tester, '1 2 3 4 5 6 7 8 9 0 1 2');
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape phone: display stays visible', (tester) async {
    // Pixel-class phone held sideways (2400x1080 px at 2.625 dpr).
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CalculatorApp());
    await tapKeys(tester, '7 + =');
    expect(tester.takeException(), isNull);
    // getRect includes FittedBox scaling, so a squeezed-out display is ~0.
    expect(
      tester.getRect(find.byKey(const Key('display'))).height,
      greaterThan(20),
    );
    expect(
      tester.getRect(find.byKey(const Key('message'))).height,
      greaterThan(8),
    );
  });
}
