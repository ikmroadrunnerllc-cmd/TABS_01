/// Left-to-right running-total calculator.
///
/// No operator precedence: 2 + 3 × 4 = (2 + 3) × 4 = 20.
/// Every user action is one method, and each method is one state transition.
class Calculator {
  static const int maxDigits = 12;

  double? _accumulator; // running total, null until the first operator
  String? _pendingOp; // '+', '−', '×', '÷'
  String _entry = '0'; // operand currently being typed (or last result)
  bool _awaitingOperand = false; // operator chosen, no digit yet
  bool _justEvaluated = false; // last action was '='
  String? _error; // e.g. division by zero
  String? _hint; // non-blocking guidance, e.g. "Enter a number first"

  String get display => _error != null ? 'Error' : _entry;
  String? get error => _error;
  String? get hint => _hint;
  String? get pendingOp => _pendingOp;
  double? get accumulator => _accumulator;
  bool get awaitingOperand => _awaitingOperand;

  /// Small line above the display, e.g. "5 ×".
  String get expression {
    if (_accumulator == null || _pendingOp == null) return '';
    return '${format(_accumulator!)} $_pendingOp';
  }

  void inputDigit(String d) {
    _hint = null;
    if (_error != null || _justEvaluated) {
      // A digit after an error or after '=' starts a fresh calculation.
      clear();
      _entry = d;
      return;
    }
    if (_awaitingOperand) {
      _entry = d;
      _awaitingOperand = false;
      return;
    }
    if (_entry.replaceFirst('-', '').length >= maxDigits) {
      _hint = 'Maximum $maxDigits digits';
      return;
    }
    _entry = _entry == '0' ? d : _entry + d;
  }

  void inputOperator(String op) {
    _hint = null;
    if (_error != null) {
      _hint = 'Press AC to start over';
      return;
    }
    _justEvaluated = false;
    if (_awaitingOperand && _pendingOp != null) {
      _pendingOp = op; // operator twice in a row: replace the pending one
      return;
    }
    final value = double.parse(_entry);
    if (_accumulator != null && _pendingOp != null) {
      final result = _apply(_accumulator!, _pendingOp!, value);
      if (result == null) return;
      _accumulator = result;
      _entry = format(result);
    } else {
      _accumulator = value;
    }
    _pendingOp = op;
    _awaitingOperand = true;
  }

  void equals() {
    _hint = null;
    if (_error != null) return;
    if (_pendingOp == null) return; // nothing to evaluate
    if (_awaitingOperand) {
      // Incomplete input like "7 + =": ignore, keep the pending operation.
      _hint = 'Enter a number after $_pendingOp';
      return;
    }
    final result = _apply(_accumulator!, _pendingOp!, double.parse(_entry));
    if (result == null) return;
    _entry = format(result);
    _accumulator = null;
    _pendingOp = null;
    _justEvaluated = true;
  }

  /// Sign toggle. Zero stays 0 (never "-0"); while awaiting an operand there
  /// is no number to flip yet, so it does nothing.
  void toggleSign() {
    _hint = null;
    if (_error != null) return;
    if (_awaitingOperand) {
      _hint = 'Enter a number first';
      return;
    }
    if (double.parse(_entry) == 0) return;
    _entry = _entry.startsWith('-') ? _entry.substring(1) : '-$_entry';
  }

  /// AC: clears display, accumulator, pending operator, result phase, error.
  void clear() {
    _accumulator = null;
    _pendingOp = null;
    _entry = '0';
    _awaitingOperand = false;
    _justEvaluated = false;
    _error = null;
    _hint = null;
  }

  double? _apply(double a, String op, double b) {
    if (op == '÷' && b == 0) {
      _fail('Cannot divide by zero');
      return null;
    }
    final r = switch (op) {
      '+' => a + b,
      '−' => a - b,
      '×' => a * b,
      '÷' => a / b,
      _ => throw ArgumentError('Unknown operator $op'),
    };
    if (!r.isFinite || r.abs() >= 1e15) {
      _fail('Number too large');
      return null;
    }
    return r;
  }

  void _fail(String message) {
    clear();
    _error = message;
  }

  /// 20.0 -> "20", 1/3 -> "0.3333333333".
  static String format(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    var s = v.toStringAsPrecision(10);
    if (s.contains('e')) return s;
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }
}
