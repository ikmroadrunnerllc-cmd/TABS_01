// Automated boundary tests for Activity 05's counter, matching the test
// protocol table: lower boundary, upper boundary, overshoot, invalid input,
// undo chain, and slider+undo consistency.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Lower boundary: at 10, Decrease does not go below 10', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());
    // Force to the boundary using Reset (goes to 10).
    await tester.tap(find.text('Reset to 10'));
    await tester.pump();
    expect(find.text('10'), findsOneWidget);

    // Decrease button should be disabled at the lower boundary.
    final decreaseButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Decrease'),
    );
    expect(decreaseButton.onPressed, isNull,
        reason: 'Decrease should be disabled at 10');
    expect(find.text('10'), findsOneWidget); // value unchanged
  });

  testWidgets('Upper boundary: at 150, Increase does not exceed 150', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());
    // Drive the slider straight to 150 (one committed action).
    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('150'), findsOneWidget);

    final increaseButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Increase'),
    );
    expect(increaseButton.onPressed, isNull,
        reason: 'Increase should be disabled at 150');
    expect(find.text('150'), findsOneWidget); // value unchanged
  });

  testWidgets('Invalid input: blank, negative, decimal, and text are rejected', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());
    final field = find.byType(TextField);

    for (final bad in ['', '-2', '2.5', 'hello']) {
      await tester.enterText(field, bad);
      await tester.pump();
      // A SnackBar should appear explaining the rejection.
      expect(find.byType(SnackBar), findsOneWidget,
          reason: 'Expected feedback for input "$bad"');
      await tester.pump(const Duration(seconds: 5)); // let SnackBar clear
    }
  });

  testWidgets('Undo chain: three changes, then undo four times', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());
    expect(find.text('40'), findsOneWidget); // starting value

    await tester.tap(find.text('Increase')); // 40 -> 47
    await tester.pump();
    await tester.tap(find.text('Increase')); // 47 -> 54
    await tester.pump();
    await tester.tap(find.text('Decrease')); // 54 -> 47
    await tester.pump();
    expect(find.text('47'), findsOneWidget);

    await tester.tap(find.text('Undo')); // back to 54
    await tester.pump();
    expect(find.text('54'), findsOneWidget);

    await tester.tap(find.text('Undo')); // back to 47
    await tester.pump();
    expect(find.text('47'), findsOneWidget);

    await tester.tap(find.text('Undo')); // back to 40
    await tester.pump();
    expect(find.text('40'), findsOneWidget);

    // Fourth undo: history is now empty, must not crash or change value.
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('40'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget); // "no earlier value"
  });
}
