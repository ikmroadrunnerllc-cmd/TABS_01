// In-Class Activity 06 — Drawing with Flutter
// Student: Mario Gutierrez
// Date: September 30, 2026

import 'dart:math' show pi, Random;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

// BLOCK 1: App shell. Nothing here changes, so it is a StatelessWidget.
class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

// BLOCK 2: The named face designs for the Level 3 gallery.
enum FaceType { classic, sleepy, surprised }

extension FaceTypeLabel on FaceType {
  String get label => switch (this) {
    FaceType.classic => 'Classic',
    FaceType.sleepy => 'Sleepy',
    FaceType.surprised => 'Surprised',
  };
}

// BLOCK 3: One snapshot of everything the painter needs. The undo stack
// stores these, and shouldRepaint compares them field by field.
class FaceConfig {
  const FaceConfig({
    this.mood = 0.8,
    this.faceColor = const Color(0xFFFFB300),
    this.eyeRadius = 0.10,
    this.eyeGap = 0.35,
    this.showBlush = false,
    this.faceType = FaceType.classic,
    this.hat = false,
    this.glasses = false,
    this.mustache = false,
  });

  final double mood; // 0.0 sad → 1.0 happy
  final Color faceColor;
  final double eyeRadius; // fraction of the face radius
  final double eyeGap; // eye distance from center, fraction of face radius
  final bool showBlush;
  final FaceType faceType;
  final bool hat;
  final bool glasses;
  final bool mustache;

  FaceConfig copyWith({
    double? mood,
    Color? faceColor,
    double? eyeRadius,
    double? eyeGap,
    bool? showBlush,
    FaceType? faceType,
    bool? hat,
    bool? glasses,
    bool? mustache,
  }) {
    return FaceConfig(
      mood: mood ?? this.mood,
      faceColor: faceColor ?? this.faceColor,
      eyeRadius: eyeRadius ?? this.eyeRadius,
      eyeGap: eyeGap ?? this.eyeGap,
      showBlush: showBlush ?? this.showBlush,
      faceType: faceType ?? this.faceType,
      hat: hat ?? this.hat,
      glasses: glasses ?? this.glasses,
      mustache: mustache ?? this.mustache,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FaceConfig &&
        other.mood == mood &&
        other.faceColor == faceColor &&
        other.eyeRadius == eyeRadius &&
        other.eyeGap == eyeGap &&
        other.showBlush == showBlush &&
        other.faceType == faceType &&
        other.hat == hat &&
        other.glasses == glasses &&
        other.mustache == mustache;
  }

  @override
  int get hashCode => Object.hash(
    mood,
    faceColor,
    eyeRadius,
    eyeGap,
    showBlush,
    faceType,
    hat,
    glasses,
    mustache,
  );
}

// BLOCK 4: Level 2 mood bands → face color.
Color colorForMood(double mood) {
  if (mood < 0.35) return Colors.lightBlue.shade300; // cool / sad
  if (mood <= 0.7) return Colors.yellow.shade600; // neutral
  return Colors.orange.shade400; // warm / happy
}

String moodLabel(double mood) {
  if (mood < 0.35) return 'Sad';
  if (mood <= 0.7) return 'Neutral';
  return 'Happy';
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing this + setState() triggers shouldRepaint.
  FaceConfig config = FaceConfig(mood: 0.8, faceColor: colorForMood(0.8));
  final List<FaceConfig> history = [];
  final Random _random = Random();

  // BLOCK 5: Every change goes through here so undo always has the
  // configuration from right before the change.
  void _apply(FaceConfig next, {bool saveHistory = true}) {
    if (next == config) return;
    setState(() {
      if (saveHistory) history.add(config);
      config = next;
    });
  }

  // Sliders fire onChanged every frame, so a whole drag becomes one undo
  // entry: remember the config at the start, save it when the drag ends.
  FaceConfig? _beforeDrag;
  void _dragStart(double _) => _beforeDrag = config;
  void _dragEnd(double _) {
    final before = _beforeDrag;
    _beforeDrag = null;
    if (before != null && before != config) setState(() => history.add(before));
  }

  void _undo() {
    if (history.isEmpty) return;
    setState(() => config = history.removeLast());
    _showMessage(
      'Undo: back to ${config.faceType.label}, '
      'mood ${config.mood.toStringAsFixed(2)}',
    );
  }

  void _showMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // old message goes away before the new one
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  // BLOCK 6: Level 4 gestures. Tap cycles faces, long-press randomizes.
  void _cycleFace() {
    final types = FaceType.values;
    final next = types[(config.faceType.index + 1) % types.length];
    _apply(config.copyWith(faceType: next));
    _showMessage('Face changed to ${next.label}');
  }

  void _randomize() {
    final mood = double.parse(_random.nextDouble().toStringAsFixed(2));
    final color = HSVColor.fromAHSV(
      1,
      _random.nextDouble() * 360,
      0.55,
      1,
    ).toColor();
    _apply(config.copyWith(mood: mood, faceColor: color));
    _showMessage(
      'Randomized: mood ${mood.toStringAsFixed(2)} '
      '(${moodLabel(mood)}) with a new face color',
    );
  }

  void _toggleAccessory(String name) {
    final next = switch (name) {
      'Hat' => config.copyWith(hat: !config.hat),
      'Glasses' => config.copyWith(glasses: !config.glasses),
      _ => config.copyWith(mustache: !config.mustache),
    };
    _apply(next);
  }

  @override
  Widget build(BuildContext context) {
    final canvas = GestureDetector(
      key: const Key('faceCanvas'),
      onTap: _cycleFace,
      onLongPress: _randomize,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            size: Size.infinite,
            painter: SmileyPainter(config: config),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: history.isEmpty ? null : _undo,
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // Portrait: face on top, controls below.
            // Landscape: face on the left, controls on the right.
            if (orientation == Orientation.portrait) {
              return Column(
                children: [
                  Expanded(flex: 5, child: canvas),
                  Expanded(flex: 4, child: _controls()),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: canvas),
                Expanded(child: _controls()),
              ],
            );
          },
        ),
      ),
    );
  }

  // BLOCK 7: Controls. Each one updates state; the painter only draws.
  Widget _controls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<FaceType>(
            segments: [
              for (final type in FaceType.values)
                ButtonSegment(value: type, label: Text(type.label)),
            ],
            selected: {config.faceType},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                _apply(config.copyWith(faceType: s.first)),
          ),
          const SizedBox(height: 8),
          Text(
            'Mood: ${config.mood.toStringAsFixed(2)} (${moodLabel(config.mood)})',
            textAlign: TextAlign.center,
          ),
          Slider(
            key: const Key('moodSlider'),
            value: config.mood,
            // Save one undo entry per drag, not one per frame.
            onChangeStart: _dragStart,
            onChangeEnd: _dragEnd,
            onChanged: (double v) => _apply(
              config.copyWith(mood: v, faceColor: colorForMood(v)),
              saveHistory: false,
            ),
          ),
          Text(
            'Eye size: ${(config.eyeRadius * 100).round()}% of radius',
            textAlign: TextAlign.center,
          ),
          Slider(
            key: const Key('eyeSlider'),
            value: config.eyeRadius,
            min: 0.06,
            max: 0.16,
            onChangeStart: _dragStart,
            onChangeEnd: _dragEnd,
            onChanged: (double v) =>
                _apply(config.copyWith(eyeRadius: v), saveHistory: false),
          ),
          Text(
            'Eye gap: ${(config.eyeGap * 100).round()}% of radius',
            textAlign: TextAlign.center,
          ),
          Slider(
            key: const Key('gapSlider'),
            value: config.eyeGap,
            min: 0.2,
            max: 0.5,
            onChangeStart: _dragStart,
            onChangeEnd: _dragEnd,
            onChanged: (double v) =>
                _apply(config.copyWith(eyeGap: v), saveHistory: false),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              FilterChip(
                label: const Text('Blush'),
                selected: config.showBlush,
                onSelected: (v) => _apply(config.copyWith(showBlush: v)),
              ),
              _accessoryButton('Hat', Icons.school, config.hat),
              _accessoryButton('Glasses', Icons.visibility, config.glasses),
              _accessoryButton('Mustache', Icons.face, config.mustache),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap the face to cycle designs · long-press to randomize',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _accessoryButton(String name, IconData icon, bool on) {
    return IconButton(
      tooltip: '${on ? 'Remove' : 'Add'} $name',
      isSelected: on,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: on
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      onPressed: () => _toggleAccessory(name),
    );
  }
}

// BLOCK 8: The painter. Every position is calculated from size, the face
// center, or the face radius, so the drawing scales with the widget.
class SmileyPainter extends CustomPainter {
  SmileyPainter({required this.config});
  final FaceConfig config;

  static const ink = Colors.black87;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // Paint order (bottom → top): face, border, blush, eyes, mouth,
    // mustache, glasses, hat. Later calls cover earlier ones.

    // 1) Face
    canvas.drawCircle(c, r, Paint()..color = config.faceColor);

    // 2) Face border
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03,
    );

    // 3) Blush
    if (config.showBlush) {
      final blush = Paint()..color = Colors.pink.withValues(alpha: 0.35);
      for (final side in [-1, 1]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx + side * r * 0.55, c.dy + r * 0.15),
            width: r * 0.3,
            height: r * 0.16,
          ),
          blush,
        );
      }
    }

    // 4) Eyes + 5) Mouth, by face design
    switch (config.faceType) {
      case FaceType.classic:
        _drawOpenEyes(canvas, c, r, 1.0);
        _drawMoodMouth(canvas, c, r);
      case FaceType.sleepy:
        _drawSleepyEyes(canvas, c, r);
        _drawSleepyMouth(canvas, c, r);
      case FaceType.surprised:
        _drawBrows(canvas, c, r);
        _drawOpenEyes(canvas, c, r, 1.5);
        _drawSurprisedMouth(canvas, c, r);
    }

    // 6) Accessories last so they sit on top
    if (config.mustache) _drawMustache(canvas, c, r);
    if (config.glasses) _drawGlasses(canvas, c, r);
    if (config.hat) _drawHat(canvas, c, r);
  }

  Paint _stroke(double width) => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  double _eyeY(Offset c, double r) => c.dy - r * 0.18;
  double _eyeDx(double r) => r * config.eyeGap;

  void _drawOpenEyes(Canvas canvas, Offset c, double r, double scale) {
    final eyeR = r * config.eyeRadius * scale;
    final eyePaint = Paint()..color = ink;
    final shine = Paint()..color = Colors.white;
    for (final side in [-1, 1]) {
      final eye = Offset(c.dx + side * _eyeDx(r), _eyeY(c, r));
      canvas.drawCircle(eye, eyeR, eyePaint);
      canvas.drawCircle(
        eye + Offset(-eyeR * 0.35, -eyeR * 0.35),
        eyeR * 0.3,
        shine,
      );
    }
  }

  void _drawSleepyEyes(Canvas canvas, Offset c, double r) {
    // Closed lids: the bottom half of a small oval, like "◡".
    final eyeW = r * config.eyeRadius * 2.6;
    for (final side in [-1, 1]) {
      final rect = Rect.fromCenter(
        center: Offset(c.dx + side * _eyeDx(r), _eyeY(c, r)),
        width: eyeW,
        height: eyeW * 0.6,
      );
      canvas.drawArc(rect, 0.1 * pi, 0.8 * pi, false, _stroke(r * 0.04));
    }
  }

  void _drawBrows(Canvas canvas, Offset c, double r) {
    final y = _eyeY(c, r) - r * config.eyeRadius * 1.5 - r * 0.12;
    for (final side in [-1, 1]) {
      final x = c.dx + side * _eyeDx(r);
      canvas.drawLine(
        Offset(x - side * r * 0.12, y - r * 0.03),
        Offset(x + side * r * 0.12, y + r * 0.03),
        _stroke(r * 0.04),
      );
    }
  }

  // Level 2: the mouth shape follows the mood bands.
  void _drawMoodMouth(Canvas canvas, Offset c, double r) {
    final mood = config.mood;
    final line = _stroke(r * 0.05);

    if (mood < 0.35) {
      // Frown: top half of an oval, lower on the face. Sadder = deeper.
      final rect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.55),
        width: r * 0.9,
        height: r * (0.5 - mood * 0.8),
      );
      canvas.drawArc(rect, 1.15 * pi, 0.70 * pi, false, line);
    } else if (mood <= 0.7) {
      // Soft smile: shallow bottom arc that deepens as mood rises.
      final rect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.2),
        width: r * 0.9,
        height: r * (0.2 + (mood - 0.35) * 0.8),
      );
      canvas.drawArc(rect, 0.2 * pi, 0.6 * pi, false, line);
    } else {
      // Big open smile: fill the half-oval, then outline it.
      final rect = Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.12),
        width: r * 1.1,
        height: r * (0.6 + (mood - 0.7) * 1.0),
      );
      canvas.drawArc(rect, 0, pi, false, Paint()..color = Colors.red.shade900);
      canvas.drawArc(rect, 0, pi, true, line);
    }
  }

  void _drawSleepyMouth(Canvas canvas, Offset c, double r) {
    final rect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + r * 0.35),
      width: r * 0.4,
      height: r * (0.1 + config.mood * 0.15),
    );
    canvas.drawArc(rect, 0.15 * pi, 0.7 * pi, false, _stroke(r * 0.04));
  }

  void _drawSurprisedMouth(Canvas canvas, Offset c, double r) {
    final rect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + r * 0.45),
      width: r * 0.3,
      height: r * (0.3 + config.mood * 0.15),
    );
    canvas.drawOval(rect, Paint()..color = Colors.red.shade900);
    canvas.drawOval(rect, _stroke(r * 0.04));
  }

  void _drawMustache(Canvas canvas, Offset c, double r) {
    // Sits between the glasses and the top of the mouth.
    final y = c.dy + r * 0.12;
    final path = Path();
    for (final side in [-1, 1]) {
      path
        ..moveTo(c.dx, y - r * 0.06)
        ..quadraticBezierTo(
          c.dx + side * r * 0.25,
          y - r * 0.2,
          c.dx + side * r * 0.42,
          y - r * 0.02,
        )
        ..quadraticBezierTo(c.dx + side * r * 0.22, y + r * 0.02, c.dx, y)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = Colors.brown.shade800);
  }

  void _drawGlasses(Canvas canvas, Offset c, double r) {
    final lensR = r * 0.2;
    final frame = _stroke(r * 0.035);
    final y = _eyeY(c, r);
    final lenses = [Offset(c.dx - _eyeDx(r), y), Offset(c.dx + _eyeDx(r), y)];
    for (final lens in lenses) {
      canvas.drawCircle(
        lens,
        lensR,
        Paint()..color = Colors.lightBlue.withValues(alpha: 0.2),
      );
      canvas.drawCircle(lens, lensR, frame);
    }
    canvas.drawLine(
      lenses[0] + Offset(lensR, 0),
      lenses[1] - Offset(lensR, 0),
      frame,
    );
  }

  void _drawHat(Canvas canvas, Offset c, double r) {
    final hatPaint = Paint()..color = Colors.indigo.shade900;
    final brimY = c.dy - r * 0.75;
    // Brim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, brimY),
          width: r * 1.5,
          height: r * 0.12,
        ),
        Radius.circular(r * 0.05),
      ),
      hatPaint,
    );
    // Crown
    final crown = Rect.fromLTRB(
      c.dx - r * 0.45,
      c.dy - r * 1.2,
      c.dx + r * 0.45,
      brimY,
    );
    canvas.drawRect(crown, hatPaint);
    // Band
    canvas.drawRect(
      Rect.fromLTRB(
        crown.left,
        brimY - r * 0.14,
        crown.right,
        brimY - r * 0.06,
      ),
      Paint()..color = Colors.red.shade400,
    );
  }

  // Repaint only when an input the painter uses actually changed.
  // FaceConfig's == compares mood, color, eye size, eye gap, blush,
  // face type, and each accessory.
  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.config != config;
  }
}
