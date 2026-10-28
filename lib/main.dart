import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

void main() {
  runApp(const HauntedMansionApp());
}

class HauntedMansionApp extends StatelessWidget {
  const HauntedMansionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Signup App',
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}
