import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RunMyApp());
}

class RunMyApp extends StatefulWidget {
  const RunMyApp({super.key});

  @override
  State<RunMyApp> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<RunMyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Special Feature: theme persistence — restore the saved ThemeMode on launch.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');
    if (savedTheme == 'dark') {
      setState(() => _themeMode = ThemeMode.dark);
    } else if (savedTheme == 'light') {
      setState(() => _themeMode = ThemeMode.light);
    }
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _saveThemePreference(themeMode);
  }

  Future<void> _saveThemePreference(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Card Demo',
      // Special Feature: Material 3 seed ColorScheme drives both themes from one seed color.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: StatusCardHome(themeMode: _themeMode, onThemeChanged: changeTheme),
    );
  }
}

class StatusCardHome extends StatelessWidget {
  const StatusCardHome({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Status Card Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: isDark ? Colors.teal : Colors.blueGrey,
              child: const Icon(Icons.person, size: 42, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Flutter Theme Lab',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Part 2 Task 1: AnimatedContainer cross-fades the badge color
            // on theme change instead of switching abruptly.
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: 220,
              height: 64,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.teal : Colors.amber,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 12, color: Colors.black87),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Status: Online',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Choose the Theme:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            // Part 2 Task 2: single Switch replaces the two theme buttons.
            Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (isOn) {
                onThemeChanged(isOn ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ],
        ),
      ),
    );
  }
}
