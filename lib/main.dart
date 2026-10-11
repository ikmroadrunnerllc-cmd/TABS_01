import 'package:flutter/material.dart';

import 'calculator.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _calc = Calculator();

  // Every button routes through setState so the UI is always derived from
  // the Calculator's state, never from scattered widget fields.
  void _act(void Function() action) => setState(action);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = _calc.error ?? _calc.hint ?? '';

    return Scaffold(
      // Landscape is short; give the height to the calculator instead.
      appBar: MediaQuery.orientationOf(context) == Orientation.landscape
          ? null
          : AppBar(title: const Text('Calculator State Lab')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    // Each line scales down in proportion, so all three stay
                    // visible even in a short landscape panel.
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _calc.expression,
                            key: const Key('expression'),
                            style: TextStyle(
                              fontSize: 22,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Semantics(
                          liveRegion: true,
                          label: 'Display',
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _calc.display,
                              key: const Key('display'),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Semantics(
                          liveRegion: true,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              message,
                              key: const Key('message'),
                              style: TextStyle(
                                fontSize: 16,
                                color: _calc.error != null
                                    ? scheme.error
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _row([
                      _key(
                        'AC',
                        _calc.clear,
                        flex: 2,
                        kind: _Kind.action,
                        label: 'All clear',
                      ),
                      _key(
                        '±',
                        _calc.toggleSign,
                        kind: _Kind.action,
                        label: 'Toggle sign',
                      ),
                      _op('÷', 'divide'),
                    ]),
                    _row([
                      _digit('7'),
                      _digit('8'),
                      _digit('9'),
                      _op('×', 'times'),
                    ]),
                    _row([
                      _digit('4'),
                      _digit('5'),
                      _digit('6'),
                      _op('−', 'minus'),
                    ]),
                    _row([
                      _digit('1'),
                      _digit('2'),
                      _digit('3'),
                      _op('+', 'plus'),
                    ]),
                    _row([
                      _digit('0', flex: 3),
                      _key(
                        '=',
                        _calc.equals,
                        kind: _Kind.equals,
                        label: 'equals',
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) =>
      Expanded(child: Row(children: children));

  Widget _digit(String d, {int flex = 1}) =>
      _key(d, () => _calc.inputDigit(d), flex: flex);

  Widget _op(String op, String label) => _key(
    op,
    () => _calc.inputOperator(op),
    kind: _Kind.operator,
    label: label,
    selected: _calc.awaitingOperand && _calc.pendingOp == op,
  );

  Widget _key(
    String text,
    void Function() onTap, {
    int flex = 1,
    _Kind kind = _Kind.digit,
    String? label,
    bool selected = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      _Kind.digit => (scheme.surfaceContainer, scheme.onSurface),
      _Kind.action => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _Kind.operator =>
        selected
            ? (scheme.onPrimaryContainer, scheme.primaryContainer)
            : (scheme.primaryContainer, scheme.onPrimaryContainer),
      _Kind.equals => (scheme.primary, scheme.onPrimary),
    };
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Semantics(
          button: true,
          selected: selected,
          label: label ?? text,
          excludeSemantics: true,
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              key: Key('key-$text'),
              borderRadius: BorderRadius.circular(16),
              onTap: () => _act(onTap),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Kind { digit, action, operator, equals }
