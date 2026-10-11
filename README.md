# Assignment 01 — Calculator State Lab (CSC 4360)

Flutter calculator with a **left-to-right running total** (no operator precedence):
`2 + 3 × 4 =` evaluates as `(2 + 3) × 4 = 20`.

**Pathway:** Undergraduate — core + 3 features: **Clear/AC**, **Error handling**, **Positive/negative**.

## Setup / build

```bash
flutter pub get
flutter run                # emulator or device
flutter test               # 26 transition + widget tests
flutter build apk          # build/app/outputs/flutter-apk/app-release.apk
```

## Code layout

- `lib/calculator.dart` — pure Dart state machine (no Flutter imports). One method per user action.
- `lib/main.dart` — UI. Every button calls `setState(() => calc.action())`; the UI is drawn only from calculator state.
- `test/calculator_test.dart` — one test per transition in the contract below.
- `test/widget_test.dart` — taps real buttons; checks small-screen (320×568) and landscape layouts.

## State

| Field | Meaning |
|---|---|
| `accumulator` | running total, `null` until the first operator |
| `pendingOp` | operator waiting for its right operand |
| `entry` | operand being typed (or last result) — what the display shows |
| `awaitingOperand` | operator chosen, no digit typed yet |
| `justEvaluated` | last key was `=` |
| `error` / `hint` | blocking error message / non-blocking guidance |

## State contract (each row is tested)

| Key sequence | Transition | Display |
|---|---|---|
| `2 + 3` | store 2 and +; start second operand | `3` |
| `×` | apply 2 + 3, accumulator = 5, wait for operand | `5` |
| `4 =` | apply 5 × 4, finish | `20` |
| `9 + × 2 =` | second operator replaces pending + | `18` |
| `7 + =` | equals ignored while awaiting operand; hint shown, + kept | `7` |
| digit after `=` | starts a fresh calculation | new digit |
| operator after `=` | result becomes the accumulator | result |
| `AC` | clear operand, accumulator, pending op, result phase, error | `0` |
| `8 ÷ 0 =` | error "Cannot divide by zero"; operators blocked; digit or AC recovers | `Error` |
| result ≥ 1e15 | error "Number too large" | `Error` |
| 13th digit | ignored, hint "Maximum 12 digits" | unchanged |
| `5 ±` | flip sign | `-5` |
| `0 ±` | zero stays 0 (never `-0`) | `0` |
| `5 + ±` | no operand to flip yet; hint shown | `5` |

## Accessibility

- Buttons announce spoken names to TalkBack ("plus", "times", "All clear", "Toggle sign").
- The display and message line are live regions, so results and errors are read aloud.
- The pending operator is highlighted *and* marked `selected` — not shown by color alone.
- The display text scales down with `FittedBox` instead of overflowing on long numbers or large text.
