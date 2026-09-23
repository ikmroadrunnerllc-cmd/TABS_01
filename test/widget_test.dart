import 'package:flutter_test/flutter_test.dart';
import 'package:widget_wars/main.dart';

void main() {
  testWidgets('Tapping a tactile button increments total taps', (tester) async {
    await tester.pumpWidget(const TactileDeckApp());
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('TURBO'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('STATUS: TURBO BOOST ACTIVATED'), findsOneWidget);
  });
}
