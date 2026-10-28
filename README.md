# The Haunted Signup Mansion

My Activity 10 signup form, split into three screens.

## Files

- `lib/main.dart` starts the app.
- `lib/screens/welcome_screen.dart` is the Foyer, with the typing title and the Enter button.
- `lib/screens/signup_screen.dart` is the Lab, with the form, the eye toggle, the date picker and the spinner.
- `lib/screens/success_screen.dart` is the Ballroom, with the name and the confetti.

## How to run

```
flutter pub get
flutter run
flutter test
```

## How it works (in my own words)

**Navigation stack:**

**Where state lives and when it dies:**

**Why dispose() matters:**

## Bugs I hit

- `pubspec.yaml` asked for Dart 3.13.7 but I have 3.13.4, so the packages wouldn't install. I changed it to `^3.13.0`.
- The old form never disposed its controllers. I added `dispose()`.
- The tip button called `setState` after waiting, without checking `mounted`. I added the check.
