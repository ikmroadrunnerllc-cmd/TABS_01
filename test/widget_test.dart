

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows the Movie Watchlist title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Movie Watchlist'), findsOneWidget);
  });
}
