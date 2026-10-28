import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclass10/main.dart';
import 'package:inclass10/screens/signup_screen.dart';
import 'package:inclass10/screens/success_screen.dart';
import 'package:inclass10/screens/welcome_screen.dart';

class _RouteCounter extends NavigatorObserver {
  int replacements = 0;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacements++;
  }
}

final _join = find.text('Create Account');

Future<void> _enterLab(WidgetTester tester) async {
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

Future<void> _fillValid(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Casper');
  await tester.enterText(fields.at(1), 'casper@mansion.com');
  await tester.enterText(fields.at(2), 'boo123');
  await tester.tap(fields.at(3));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

bool _passwordObscured(WidgetTester tester) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).at(2),
        matching: find.byType(EditableText),
      ),
    )
    .obscureText;

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 2.5;
  });

  testWidgets('1. empty submit fires every validator', (tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await _enterLab(tester);
    await tester.tap(_join);
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Pick your birth date'), findsOneWidget);
  });

  testWidgets('2. bad email + 5-char password', (tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await _enterLab(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Casper');
    await tester.enterText(fields.at(1), 'casper.mansion.com');
    await tester.enterText(fields.at(2), 'boo12');
    await tester.tap(_join);
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.text('Please enter your name'), findsNothing);
  });

  testWidgets('3. eye toggle flips obscureText, validator still fires',
      (tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await _enterLab(tester);
    await tester.enterText(find.byType(TextFormField).at(2), 'boo');
    expect(_passwordObscured(tester), isTrue);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(_passwordObscured(tester), isFalse);
    await tester.tap(_join);
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(_passwordObscured(tester), isTrue);
    await tester.tap(_join);
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('4. picker caps at today and empty date blocks submit',
      (tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await _enterLab(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Casper');
    await tester.enterText(fields.at(1), 'casper@mansion.com');
    await tester.enterText(fields.at(2), 'boo123');
    await tester.tap(_join);
    await tester.pump();
    expect(find.text('Pick your birth date'), findsOneWidget);
    expect(find.byType(SignupScreen), findsOneWidget);

    await tester.tap(fields.at(3));
    await tester.pumpAndSettle();
    final dialog = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    expect(dialog.lastDate.isAfter(DateTime.now()), isFalse);
    expect(dialog.firstDate, DateTime(1920));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('1/1/2008'), findsOneWidget);
  });

  testWidgets('5. back from lab returns to foyer with a fresh form',
      (tester) async {
    await tester.pumpWidget(const HauntedMansionApp());
    await _enterLab(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'Casper');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await _enterLab(tester);
    expect(find.text('Casper'), findsNothing);
  });

  testWidgets('6+7+8. one navigation, no resubmit, confetti survives re-entry',
      (tester) async {
    final counter = _RouteCounter();
    await tester.pumpWidget(
      MaterialApp(home: const WelcomeScreen(), navigatorObservers: [counter]),
    );
    await _enterLab(tester);
    await _fillValid(tester);

    await tester.tap(_join);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(counter.replacements, 1);
    expect(find.text('Welcome, Casper!'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SuccessScreen), findsNothing);
    expect(find.byType(SignupScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    await _enterLab(tester);
    await _fillValid(tester);
    await tester.tap(_join);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Back to Home'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SuccessScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(counter.replacements, 2);
    expect(tester.takeException(), isNull);
  });
}
