// Automated checks for Activity 06: shouldRepaint, gestures, SnackBar
// feedback, undo, and phone-sized layouts in portrait and landscape.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

SmileyPainter currentPainter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byKey(const Key('faceCanvas')),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as SmileyPainter;
}

void setPhone(WidgetTester tester, Size size) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('shouldRepaint', () {
    const base = FaceConfig();

    test('false when nothing changed', () {
      expect(
        SmileyPainter(config: base)
            .shouldRepaint(SmileyPainter(config: const FaceConfig())),
        isFalse,
      );
    });

    test('true when any single input changes', () {
      final changes = [
        base.copyWith(mood: 0.2),
        base.copyWith(faceColor: Colors.blue),
        base.copyWith(eyeRadius: 0.15),
        base.copyWith(eyeGap: 0.45),
        base.copyWith(showBlush: true),
        base.copyWith(faceType: FaceType.sleepy),
        base.copyWith(hat: true),
        base.copyWith(glasses: true),
        base.copyWith(mustache: true),
      ];
      for (final next in changes) {
        expect(
          SmileyPainter(config: next)
              .shouldRepaint(SmileyPainter(config: base)),
          isTrue,
        );
      }
    });
  });

  test('mood bands pick cool / yellow / warm colors', () {
    expect(colorForMood(0.1), Colors.lightBlue.shade300);
    expect(colorForMood(0.5), Colors.yellow.shade600);
    expect(colorForMood(0.9), Colors.orange.shade400);
  });

  testWidgets('mood slider updates painter mood and color', (tester) async {
    setPhone(tester, const Size(412, 915));
    await tester.pumpWidget(const SmileyApp());
    await tester.drag(
      find.byKey(const Key('moodSlider')),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();
    final config = currentPainter(tester).config;
    expect(config.mood, 0.0);
    expect(config.faceColor, colorForMood(0.0));
    expect(find.textContaining('(Sad)'), findsOneWidget);

    // A whole drag is one undo step.
    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();
    expect(currentPainter(tester).config.mood, 0.8);
  });

  testWidgets('tap cycles faces and shows one SnackBar', (tester) async {
    setPhone(tester, const Size(412, 915));
    await tester.pumpWidget(const SmileyApp());
    await tester.tap(find.byKey(const Key('faceCanvas')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('faceCanvas')));
    await tester.pumpAndSettle();
    expect(currentPainter(tester).config.faceType, FaceType.surprised);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Face changed to Surprised'), findsOneWidget);
  });

  testWidgets('long-press randomizes and undo restores', (tester) async {
    setPhone(tester, const Size(412, 915));
    await tester.pumpWidget(const SmileyApp());
    final before = currentPainter(tester).config;
    await tester.longPress(find.byKey(const Key('faceCanvas')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Randomized'), findsOneWidget);
    expect(currentPainter(tester).config.faceColor, isNot(before.faceColor));

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();
    expect(currentPainter(tester).config, before);
  });

  testWidgets('accessories toggle independently; undo steps back', (
    tester,
  ) async {
    setPhone(tester, const Size(412, 915));
    await tester.pumpWidget(const SmileyApp());
    await tester.tap(find.byTooltip('Add Hat'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add Glasses'));
    await tester.pump();
    var config = currentPainter(tester).config;
    expect([config.hat, config.glasses, config.mustache], [true, true, false]);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    config = currentPainter(tester).config;
    expect([config.hat, config.glasses], [true, false]);
  });

  for (final phone in {
    'Pixel portrait': const Size(412, 915),
    'Pixel landscape': const Size(915, 412),
    'iPhone SE portrait': const Size(375, 667),
    'iPhone SE landscape': const Size(667, 375),
  }.entries) {
    testWidgets('no overflow on ${phone.key}', (tester) async {
      setPhone(tester, phone.value);
      await tester.pumpWidget(const SmileyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
