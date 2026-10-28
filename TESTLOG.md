# Test Log

**Date:** 2026-10-28 · Flutter 3.47.5 / Dart 3.13.4 · Windows 10

All 8 cases are automated in `test/flow_test.dart`. Running `flutter test` printed
`All tests passed!`. `flutter analyze` printed `No issues found!`.
The last column is for checking each case by hand with `flutter run`.

| # | Test | Result | What happened | Checked by hand |
|---|------|--------|---------------|-----------------|
| 1 | Submit an empty form | PASS | Four errors showed: "Please enter your name", "Please enter your email", "Please enter a password" and "Pick your birth date". | ☐ |
| 2 | Bad email and short password | PASS | With `casper.mansion.com` and `boo12`, the email field said "Please enter a valid email" and the password field said "Password must be at least 6 characters". The name field had no error. | ☐ |
| 3 | Show/hide password button | PASS | The password starts hidden. Tapping the eye shows it, tapping again hides it. The password check still worked both ways. | ☐ |
| 4 | Birth date picker | PASS | Without a date, the form showed "Pick your birth date" and didn't submit. The picker doesn't allow dates after today. Pressing OK filled in `1/1/2008`. | ☐ |
| 5 | Back from Sign Up | PASS | After typing a name and pressing back, the app returned to Welcome. When Sign Up was opened again, the form was empty. | ☐ |
| 6 | Back from Success | PASS | Pressing the system back button on Success went to Welcome, not back to the form. | ☐ |
| 7 | Tapping submit twice | PASS | After the first tap the spinner showed and the button stopped working. The app only moved to Success once. | ☐ |
| 8 | Confetti and going through again | PASS | Confetti played on Success. Going back home and signing up a second time worked with no errors. | ☐ |
