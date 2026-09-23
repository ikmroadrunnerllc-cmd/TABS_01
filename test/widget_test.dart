import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_wars/main.dart';

void main() {
  Future<void> tapPad(WidgetTester tester, String label, int times) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Engagement pads update weighted score and last action', (
    tester,
  ) async {
    await tester.pumpWidget(const ViralStudioApp());

    await tapPad(tester, 'LIKE +1', 1);
    await tapPad(tester, 'SHARE +3', 1);

    expect(find.text('Trending progress: 4 / 20 pts'), findsOneWidget);
    expect(find.text('LAST ACTION: SHARED'), findsOneWidget);
    expect(find.text('TRENDING 🔥'), findsNothing);
  });

  testWidgets('Reaching 20 points reveals TRENDING banner; reset hides it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ViralStudioApp());

    await tapPad(tester, 'SHARE +3', 6); // 18
    expect(find.text('TRENDING 🔥'), findsNothing);
    await tapPad(tester, 'SAVE +2', 1); // 20
    expect(find.text('TRENDING 🔥'), findsOneWidget);

    await tester.tap(find.text('RESET POST'));
    await tester.pumpAndSettle();
    expect(find.text('TRENDING 🔥'), findsNothing);
  });

  testWidgets('Theme toggle switches to light mode', (tester) async {
    await tester.pumpWidget(const ViralStudioApp());
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    await tester.tap(find.byTooltip('Toggle Theme'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}
