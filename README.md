# The Haunted Signup Mansion

This is my Activity 10 signup form, split into three screens:

| Screen | File | What it does |
|--------|------|--------------|
| Welcome | `lib/screens/welcome_screen.dart` | Types out "The Haunted Mansion" letter by letter and has an **Enter If You Dare** button. |
| Sign Up | `lib/screens/signup_screen.dart` | The original name, email and password form, plus a show/hide password button, a birth date picker and a 2-second loading spinner. |
| Success | `lib/screens/success_screen.dart` | Says "Welcome, [name]!", plays confetti and has a **Back to the Foyer** button. |

`lib/main.dart` only starts the app and opens the Welcome screen.

## How to run it

```
flutter pub get
flutter run
flutter test      # runs all 8 test cases (see TESTLOG.md)
flutter analyze   # should say "No issues found!"
```

## What changed from Activity 10

- The form moved from `main.dart` into `signup_screen.dart`. The name, email and password checks are
  the same as before, with the same error messages (lines 122, 139 and 168).
- The text controllers are now cleaned up in `dispose()` (lines 41-47). The old version never did this.
- The "Get a signup tip" button is still there. It now checks `mounted` after its 1-second wait
  (line 52), so leaving the screen while it loads doesn't cause an error. I also fixed the typos in the tips.
- `pubspec.yaml` needed Dart 3.13.7, but this computer has 3.13.4. I changed it to `^3.13.0` so the
  packages could install.
- New packages: `animated_text_kit` (typing animation) and `confetti`.

## How moving between screens works

1. **Welcome → Sign Up** uses `Navigator.push` (`welcome_screen.dart:54`). The Welcome screen stays
   underneath, so the back arrow returns to it. Anything typed in the form is cleared when you go back.
2. **Sign Up → Success** uses `Navigator.pushReplacement` (`signup_screen.dart:87`). This removes the
   form from the stack, so pressing Back on the Success screen goes to Welcome, not back to the form.
   That way the form can't be submitted twice.
3. **Back to the Foyer** uses `Navigator.popUntil(context, (route) => route.isFirst)`
   (`success_screen.dart:68`). It goes all the way back to the Welcome screen.

## Problems handled

| Problem | Fix | Line |
|---------|-----|------|
| Keyboard covers the form | The form is inside a `SingleChildScrollView` | `signup_screen.dart:103` |
| Updating a screen that was already closed | `if (!mounted) return;` after each wait | `signup_screen.dart:52, 71, 84` |
| Tapping the button twice | The button is turned off while loading | `signup_screen.dart:195` |
| Picking a future birthday | `lastDate: DateTime.now()` | `signup_screen.dart:69` |
| No birthday picked | Shows "Pick your birth date" | `signup_screen.dart:188` |
| Confetti causing errors | Started in `initState`, cleaned up in `dispose` | `success_screen.dart:17-27` |

## Testing

All 8 test cases pass. Details are in [TESTLOG.md](TESTLOG.md). Note that test 1 says three error
messages should show, but you actually see four, because the birth date field has its own check.
