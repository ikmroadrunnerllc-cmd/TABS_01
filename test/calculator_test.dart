import 'package:calculator_app/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feeds a key sequence like '2 + 3 × 4 =' into a fresh calculator.
Calculator run(String keys) {
  final c = Calculator();
  for (final k in keys.split(' ')) {
    switch (k) {
      case '+' || '−' || '×' || '÷':
        c.inputOperator(k);
      case '=':
        c.equals();
      case '±':
        c.toggleSign();
      case 'AC':
        c.clear();
      default:
        for (final d in k.split('')) {
          c.inputDigit(d);
        }
    }
  }
  return c;
}

void main() {
  group('Core state contract', () {
    test('2 + 3 shows the second operand', () {
      final c = run('2 + 3');
      expect(c.display, '3');
      expect(c.accumulator, 2);
      expect(c.pendingOp, '+');
    });

    test('operator after operand applies pending op (running total)', () {
      final c = run('2 + 3 ×');
      expect(c.display, '5');
      expect(c.accumulator, 5);
      expect(c.pendingOp, '×');
      expect(c.awaitingOperand, isTrue);
    });

    test('left to right, no precedence: 2 + 3 × 4 = 20', () {
      expect(run('2 + 3 × 4 =').display, '20');
    });

    test('second operator replaces the pending one: 9 + × 2 = 18', () {
      final c = run('9 + ×');
      expect(c.pendingOp, '×');
      expect(c.display, '9');
      expect(run('9 + × 2 =').display, '18');
    });

    test('equals with no new operand is ignored: 7 + =', () {
      final c = run('7 + =');
      expect(c.display, '7');
      expect(c.pendingOp, '+');
      expect(c.hint, isNotNull);
      expect(run('7 + = 1 =').display, '8'); // pending op still works
    });

    test('digit after equals starts a fresh calculation', () {
      final c = run('2 + 3 = 4');
      expect(c.display, '4');
      expect(c.accumulator, isNull);
      expect(c.pendingOp, isNull);
      expect(run('2 + 3 = 4 + 1 =').display, '5');
    });

    test('operator after equals continues from the result', () {
      expect(run('2 + 3 = × 4 =').display, '20');
    });

    test('all four operations chain left to right', () {
      expect(run('8 − 2 × 3 ÷ 4 + 1 =').display, '5.5');
      expect(run('10 ÷ 4 =').display, '2.5');
      expect(run('1 ÷ 3 =').display, '0.3333333333');
    });

    test('multi-digit entry and no leading zeros', () {
      expect(run('0 0 1 2').display, '12');
    });
  });

  group('Feature: Clear / AC', () {
    test('AC clears display, accumulator, pending op and result phase', () {
      final c = run('5 + 3 × AC');
      expect(c.display, '0');
      expect(c.accumulator, isNull);
      expect(c.pendingOp, isNull);
      expect(c.awaitingOperand, isFalse);
      expect(c.expression, '');
    });

    test('no stale accumulator after AC', () {
      expect(run('5 + 3 × AC 2 + 2 =').display, '4');
    });
  });

  group('Feature: Error handling', () {
    test('division by zero shows a recoverable error', () {
      final c = run('8 ÷ 0 =');
      expect(c.display, 'Error');
      expect(c.error, 'Cannot divide by zero');
    });

    test('division by zero mid-chain also errors', () {
      expect(run('8 ÷ 0 +').display, 'Error');
    });

    test('operators are blocked while in error; AC recovers', () {
      final c = run('8 ÷ 0 = +');
      expect(c.display, 'Error');
      expect(c.hint, contains('AC'));
      expect(run('8 ÷ 0 = AC 1 + 1 =').display, '2');
    });

    test('a digit after an error starts fresh', () {
      expect(run('8 ÷ 0 = 4 + 1 =').display, '5');
    });

    test('overflow is reported instead of showing garbage', () {
      expect(run('999999999999 × 999999999999 =').error, 'Number too large');
    });

    test('digit entry is capped', () {
      final c = run('1234567890123');
      expect(c.display, '123456789012');
      expect(c.hint, isNotNull);
    });
  });

  group('Feature: Positive / negative', () {
    test('toggles a value both ways', () {
      expect(run('5 ±').display, '-5');
      expect(run('5 ± ±').display, '5');
    });

    test('zero stays 0, never -0', () {
      expect(run('±').display, '0');
      expect(run('0 ±').display, '0');
    });

    test('empty operand (after operator) is ignored with a hint', () {
      final c = run('5 + ±');
      expect(c.display, '5');
      expect(c.hint, isNotNull);
      expect(c.pendingOp, '+');
    });

    test('negative values calculate correctly', () {
      expect(run('5 ± + 3 =').display, '-2');
      expect(run('4 × 3 ± =').display, '-12');
    });

    test('toggling a result then continuing', () {
      expect(run('2 + 3 = ± + 1 =').display, '-4');
    });
  });
}
