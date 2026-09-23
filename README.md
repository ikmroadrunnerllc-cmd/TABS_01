# Activity 04: Flutter Widget Wars & State Derby

## Team Members

- **Team Name:** TODO
- TODO Full Name (Student ID: TODO)
- TODO Full Name (Student ID: TODO)
- **Shared evidence Google Doc:** TODO link

## How to Run

```bash
flutter pub get
flutter run -d chrome   # or: flutter run -d linux / an Android device
flutter test
flutter run -d chrome -t lib/round2_bug_hunt_fixed.dart   # Round 2 fixed app
```

## Build Challenge

- **Theme:** Viral Content Studio, a social-media post simulator.
- **State variables** (in `_ContentStudioScreenState`):
  - `int likes`, `int comments`, `int shares`, `int saves`: engagement counters.
  - `int streak`: engagements in a row since the last reset.
  - `double trendingTarget` (default 20): points needed to trend, set with the slider (10–50).
  - `String lastAction`: the most recent engagement, shown on the post card.
  - `engagementScore` and `isTrending` are **getters derived from the counters**, not stored fields, so they can never get out of sync.
- **Scoring:** Like +1, Comment +2, Share +3, Save +2.
- **Condition:** when `engagementScore >= trendingTarget`, the screen background turns orange, the progress meter turns orange, and the **TRENDING 🔥** banner appears. **Reset Post** clears the counters.
- **Checkpoints covered:**
  1. Stateless widgets: `PostHeaderCard`, `MetricBadge`, `TrendingBanner`.
  2. Custom Stateful widget: `EngagementPad`.
  3. Buttons: 4 engagement pads + Reset Post.
  4. Live meter: metric badges + `LinearProgressIndicator`, updated through `setState()`.
  5. Theme switcher: dark/light toggle in the AppBar.
  6. GestureDetector: pads scale down and swap raised → sunken neomorphic shadows.
- **Screenshot of changed UI state** (score 11 ≥ target 10, TRENDING unlocked):

  <img src="screenshots/trending_dark.png" width="260"> <img src="screenshots/trending_light.png" width="260">

- **Demo:** [`evidence/TeamName-Demo.gif`](evidence/TeamName-Demo.gif)

## State Defense

**Stateless vs. Stateful.** `PostHeaderCard`, `MetricBadge`, and `TrendingBanner` are `StatelessWidget`s. They only display the values their parent passes in and hold nothing that changes over time. `ViralStudioApp`, `ContentStudioScreen`, and `EngagementPad` are `StatefulWidget`s because each owns data that changes after the first build. The root owns the theme flag, the screen owns the engagement counters and trending target, and each pad owns only its own `isPressed` flag. Each piece of state lives in the lowest widget that needs it. Press state stays inside each pad, so pressing one pad never affects the others. The counters live on the screen because the badges, meter, banner, and background all read them.

**How `setState()` drives rebuilds.** Every change goes through `setState()`: a pad tap, a slider drag, a reset, or a theme toggle. `setState()` runs the change, then marks that `State`'s element as dirty. On the next frame Flutter rebuilds only that widget and the widgets under it. A pad press rebuilds just that one pad. An engagement callback rebuilds the screen, which passes new values down to the stateless badges and meter. `engagementScore` and `isTrending` are computed getters, so one counter update changes the score, the meter, the banner, and the background in the same rebuild. Changing a field without `setState()` would update the value but never schedule a redraw. That was the "Silent Mutator" bug from Round 2.

**Lifting state up and callbacks.** The theme has to affect `MaterialApp` as well as the screen, so `isDarkMode` is lifted to `ViralStudioApp`, the lowest ancestor both share. The value flows down as `isDark`, and change requests flow back up through the `onToggleTheme` callback. Pads work the same way: `EngagementPad` knows nothing about scores. It calls `onPressed` in `onTapUp`, and the parent decides what that means. That keeps the pad reusable for any action, and each pad handles its own `onTapCancel` so an interrupted touch never sticks in the pressed state.

## Round 1 Findings

TODO: paste the auto-generated team score report from the Widget Identification Blitz.

## Round 2 Bug Fixes

Full write-ups with fixed-result screenshots are in the shared Google Doc (linked above).

**Bug 1: Scope Failure.** One `isPressed` flag on the screen was shared by all four buttons, so pressing one sank all four.
```dart
// Deleted `bool isPressed = false;` from _ControlDeckScreenState.
// TactileButton is a StatefulWidget again, with its own flag:
class _TactileButtonState extends State<TactileButton> {
  bool isPressed = false;
```
*Why:* each button's `State` now owns a separate flag, so a press only rebuilds and sinks that one button.

**Bug 2: Silent Mutator.** The slider assigned `powerLevel` without telling the framework to redraw.
```dart
onChanged: (newVal) => setState(() => powerLevel = newVal),
```
*Why:* `setState()` marks the screen dirty, so the thumb, the "Power Calibration" label, and the Energy Level card redraw with the new value.

**Bug 3: Geometry Inversion.** The shadow branches were swapped: pressed used the large 8px raised shadow and unpressed used the small 2px one.
```dart
boxShadow: isPressed
    ? [ /* Offset(2, 2) / (-2, -2), blurRadius: 4  -> sunken */ ]
    : [ /* Offset(8, 8) / (-8, -8), blurRadius: 16 -> raised */ ],
```
*Why:* small, tight shadows make the button look pushed in, and large, soft shadows make it look raised, so the button now sinks when pressed instead of popping up.

**Bug 4: Event Race.** `onTapDown` called both the press and release handlers, so the action fired on first touch and the pressed state was cleared immediately. `onTapUp` was empty and there was no `onTapCancel`.
```dart
onTapDown: (_) => setState(() => isPressed = true),
onTapUp: (_) {
  setState(() => isPressed = false);
  widget.onPressed();
},
onTapCancel: () => setState(() => isPressed = false),
```
*Why:* the button now stays sunken while held, fires its action only after a completed tap, and resets safely if the touch is dragged off or cancelled.

## Graduate Extension: setState() vs. ValueNotifier

`setState()` is Flutter's simplest state tool. A `State` object changes its own fields inside the callback, and the framework marks that element dirty and rebuilds its whole `build()` method on the next frame. That works well for this app because each piece of state has one clear owner: the root owns the theme, the screen owns the counters, and each pad owns its press flag. The cost is scope. A `setState()` call rebuilds everything under that `State`, so when the slider moves, the post card, all six badges, the four pads, and the reset button rebuild too, even though most of them didn't change. State is also tied to the widget that owns it, so sharing it with a distant widget means passing values and callbacks down through every widget in between.

`ValueNotifier<T>` is a small `ChangeNotifier` built into Flutter that holds one value and notifies its listeners whenever that value is replaced. Paired with `ValueListenableBuilder`, only the builder subtree that listens to the notifier rebuilds. The widget that creates the notifier doesn't rebuild at all. That makes updates more targeted: the slider could drive a `ValueNotifier<double>`, and only the percentage label and the Slider itself would rebuild on each drag frame. Because the notifier is a plain object, it can be passed to or shared between widgets that aren't parent and child, with no extra callbacks to thread through.

The tradeoffs are lifecycle and discipline. A notifier must be created in `initState()` (or owned by a long-lived object) and disposed in `dispose()`, or it leaks listeners. Mutating a field inside the value, such as adding to a list, doesn't notify anyone, which is the same "silent mutator" trap as Bug #2. You must assign a new value. For a single-screen activity like this one, `setState()` is clearer and easier to explain. `ValueNotifier` pays off when one value drives a small part of a large tree, or when several unrelated widgets need to watch the same value. It's also the building block that Provider and Riverpod are based on.

Official documentation: <https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html>

```text
// Pseudocode: powerLevel with ValueNotifier instead of setState()
class ScreenState:
  final powerLevel = ValueNotifier<double>(65.0)     // created once
  dispose(): powerLevel.dispose()                    // avoid listener leaks

  build():
    ValueListenableBuilder(listenable: powerLevel,      // only this subtree rebuilds
      builder: (value) => Column(
        Text("Power: ${value.toInt()}%"),
        Slider(value: value, onChanged: (v) => powerLevel.value = v)))  // no setState()
```
