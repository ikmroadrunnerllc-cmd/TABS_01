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

  testWidgets('Pad fires only on release, not on touch down', (tester) async {
    await tester.pumpWidget(const ViralStudioApp());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('LIKE +1')),
    );
    await tester.pump();
    expect(find.text('Trending progress: 0 / 20 pts'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Trending progress: 1 / 20 pts'), findsOneWidget);
  });

  testWidgets('Dragging off a pad cancels the tap without firing', (
    tester,
  ) async {
    await tester.pumpWidget(const ViralStudioApp());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('SHARE +3')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, 300));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Trending progress: 0 / 20 pts'), findsOneWidget);
  });

  testWidgets('Pads are exposed to screen readers as buttons', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const ViralStudioApp());

    expect(
      tester.getSemantics(find.bySemanticsLabel('LIKE +1')),
      matchesSemantics(label: 'LIKE +1', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });
}
