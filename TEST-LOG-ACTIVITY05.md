# Activity 05 — Test Log

Ran with: `flutter test test/counter_test.dart`
Result: **All 6 tests passed** (see raw output at the bottom).

Each row below states the exact before/after values the automated test
verified, matching the required test protocol table.

| Case | Action | Value before | Value after | Result | Notes |
|---|---|---|---|---|---|
| Lower boundary | At 10, tap Decrease | 10 | 10 (unchanged) | PASS | `Decrease` button's `onPressed` is `null` (disabled) at 10 |
| Upper boundary | Drag slider to 150, tap Increase | 150 | 150 (unchanged) | PASS | `Increase` button's `onPressed` is `null` (disabled) at 150 |
| Overshoot | At 143, set increment to 20, tap Increase (143 + 20 = 163 > 150) | 143 | 143 (unchanged) | PASS | `Increase` self-disables before the tap even registers, since `canIncrease` is `false` |
| Invalid input | Enter `''`, `-2`, `2.5`, `hello` into increment field | increment stays 7 throughout | increment stays 7 | PASS | Each entry produces a `SnackBar`; `int.tryParse` returns `null` or a non-positive value for all four |
| Undo chain | From 40: Increase→47, Increase→54, Decrease→47, then Undo ×4 | 40 → 47 → 54 → 47 | Undo→54, Undo→47, Undo→40, 4th Undo→40 (no crash) | PASS | History list correctly empties; 4th undo shows "no earlier value" `SnackBar` and does not change the counter |
| Slider consistency | Drag slider away from 40, then tap Undo | 40 → (dragged value) | back to 40 | PASS | Counter text and `History: none` line agree after the undo; no leftover entry from the single `onChangeEnd` commit |

## What each test actually did (method-level trace)

- **Lower/Upper boundary**: confirmed via the disabled-button check
  (`ElevatedButton.onPressed == null`), which is the proactive UI
  improvement — the constraint is visible before the tap, not only after.
- **Overshoot**: reached 143 deterministically (Reset to 10, then 19 taps
  of Increase at the default increment of 7: 10 + 19×7 = 143), then set
  increment to 20 so 143 + 20 = 163 would violate the 150 maximum.
- **Invalid input**: each of the four values run through `_readIncrement`,
  where `int.tryParse` returns `null` for `''`, `2.5`, and `hello`, and a
  non-positive int for `-2` — all four are rejected by the same
  `if (value == null || value <= 0)` check.
- **Undo chain**: traces `_history` through three real, valid changes,
  then four `_undo()` calls, confirming `removeLast()` restores values in
  exact reverse order and that calling `_undo()` on an empty list is
  harmless (shows a message, does not throw or change `_counter`).
- **Slider consistency**: confirms `onChangeEnd` (not `onChanged`) is the
  only slider event that calls `_moveTo` and records history, so a single
  drag produces exactly one history entry, and undoing it returns to the
  exact prior state with `history` empty again.

## Raw terminal output

```
00:00 +0: loading C:/Users/lolst/Desktop/CW-2/flutter_application_1/test/counter_test.dart
00:00 +0: Lower boundary: at 10, Decrease does not go below 10
00:00 +1: Upper boundary: at 150, Increase does not exceed 150
00:00 +2: Invalid input: blank, negative, decimal, and text are rejected
00:01 +3: Undo chain: three changes, then undo four times
00:01 +4: Overshoot: an increment that would pass 150 is rejected
00:01 +5: Slider consistency: drag then undo restores the prior value
00:01 +6: All tests passed!
```

## What this log does not cover

This log is from automated widget tests, which run the real app code and
are genuine evidence of its logic — but the assignment also expects manual,
hands-on verification (running the actual release APK on a device/emulator,
screenshots, and a live walkthrough). Automated tests are not a
substitute for that manual pass; use this log alongside your own screen
captures, not instead of them.
