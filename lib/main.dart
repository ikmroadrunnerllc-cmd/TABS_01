// BLOCK 1: Import Flutter's Material widgets and launch the app.
import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

// BLOCK 2: This app shell does not change, so it is a StatelessWidget.
class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterPage(),
    );
  }
}

// BLOCK 3: This screen changes after user interactions, so it is stateful.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // BLOCK 4: State fields determine what the user sees at any moment.
  int _counter = 40;
  int _increment = 7;
  final List<int> _history = [];
  final TextEditingController _incrementController =
      TextEditingController(text: '7');

  @override
  void dispose() {
    // Controllers use resources; dispose them when this screen is removed.
    _incrementController.dispose();
    super.dispose();
  }

  // BLOCK 5: Helper methods enforce rules before they change UI state.
  bool _isValidValue(int value) => value >= 10 && value <= 150;

  // Activity 05 color-feedback rule, driven by the same counter state.
  Color _counterColor() {
    if (_counter == 10) return Colors.red;
    if (_counter > 90) return Colors.green;
    return Colors.black;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _moveTo(int nextValue) {
    // Reject the action before changing state or creating a history record.
    if (!_isValidValue(nextValue)) {
      // Name which limit was hit, since "must stay between" doesn't say
      // whether the user overshot the top or the bottom.
      final limit = nextValue < 10 ? 'minimum of 10' : 'maximum of 150';
      _showMessage('Blocked: that would go below/above the $limit.');
      return;
    }

    setState(() {
      _history.add(_counter); // Save only the state that can be restored.
      _counter = nextValue;
    });
  }

  void _readIncrement(String input) {
    final value = int.tryParse(input);
    // TODO (completed): explain exactly what input is accepted, since the
    // old message ("Enter a positive whole number.") didn't say why a
    // decimal like "2.5" or blank text was rejected.
    if (value == null || value <= 0) {
      _showMessage(
        'Increment must be a whole number greater than 0 '
        '(decimals, blanks, letters, and negatives are not allowed). '
        'Keeping increment at $_increment.',
      );
      return; // Keep the last valid increment unchanged.
    }
    setState(() => _increment = value);
  }

  void _undo() {
    if (_history.isEmpty) {
      _showMessage('There is no earlier value to restore.');
      return;
    }
    setState(() => _counter = _history.removeLast());
  }

  void _reset() {
    if (_counter != 10) _moveTo(10);
  }

  // TODO (completed): decide whether every slider tick should enter history.
  // Decision: no. onChanged fires continuously while dragging, so recording
  // history on every tick would flood the undo list with dozens of
  // intermediate values from one drag gesture, making "undo" restore
  // almost nothing meaningful per press. Instead, onChanged only updates the
  // live display value (no history), and onChangeEnd -- fired once, when the
  // user releases the slider -- is the single action that commits the change
  // and records exactly one history entry, consistent with how a button
  // press only ever counts as one action.
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    // BLOCK 6: Build reads state and connects widgets to user actions.
    final displayValue = _draggingValue ?? _counter.toDouble();

    // UI improvement (justified): preview whether Increase/Decrease would be
    // rejected, and disable the button before the user taps it, instead of
    // only telling them after a rejected action. This makes the 10-150
    // constraint visible ahead of time rather than reactive-only.
    final canIncrease = _isValidValue(_counter + _increment);
    final canDecrease = _isValidValue(_counter - _increment);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 05 Counter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$_counter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: _counterColor(),
                  ),
            ),
            Slider(
              value: displayValue,
              min: 10,
              max: 150,
              divisions: 140,
              onChanged: (value) => setState(() => _draggingValue = value),
              onChangeEnd: (value) {
                setState(() => _draggingValue = null);
                _moveTo(value.round());
              },
            ),
            TextField(
              controller: _incrementController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Increment amount (starts at 7)',
              ),
              onChanged: _readIncrement,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      canDecrease ? () => _moveTo(_counter - _increment) : null,
                  child: const Text('Decrease'),
                ),
                ElevatedButton(
                  onPressed:
                      canIncrease ? () => _moveTo(_counter + _increment) : null,
                  child: const Text('Increase'),
                ),
                OutlinedButton(onPressed: _reset, child: const Text('Reset to 10')),
                OutlinedButton(onPressed: _undo, child: const Text('Undo')),
              ],
            ),
            const SizedBox(height: 20),
            Text(_history.isEmpty ? 'History: none' : 'History: ${_history.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
