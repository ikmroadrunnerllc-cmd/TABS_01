import 'package:flutter/material.dart';

enum LoadState { idle, loading, done, error }

void main() {
  runApp(const MyApp());
}

// 🧓 Great-Grandparent
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fun Signup App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 🔑 The Global Key - acts like a remote control for the form
  final _formKey = GlobalKey<FormState>();

  final Map<String, List<String>> _tips = {
    'password_help': [
      'Please make sure to make sure your passoword is min of 10 char ',
      'Dont share your password with anyone that you dont trust ',
      'A password is somthing that should be kept stored in a password manager or encrupted vault '
    ]
  };
  
  final String _category = 'password_help';
  int _tipIndex = 0;
  LoadState _state = LoadState.idle;
  String _tipText = '';
  bool _simulateError = false;

  // 📝 Controllers to track what the user types
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _getTip() async {
    setState(() => _state = LoadState.loading);
    await Future.delayed(const Duration(seconds: 1));
    if (_simulateError) {
      setState(() => _state = LoadState.error);
      return;
    }
    setState(() {
      _tipText = _tips[_category]![_tipIndex % 3];
      _tipIndex++;
      _state = LoadState.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👨 Parent
      appBar: AppBar(
        title: const Text('Join Us Today for the Snack Club!'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // 👶 Child
          key: _formKey,
          // 3. Wrapped the Column in a SingleChildScrollView
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 👤 Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 📧 Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 🔒 Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 🚀 Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Demo signup complete — your form passed validation!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // 4. Changed from Colors.purple to Colors.orange
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _getTip,
                  child: const Text('Get a signup tip'),
                ),
                const SizedBox(height: 16),
                
                // 1. The error switch (5 lines)
                SwitchListTile(
                  title: const Text('Simulate Error'),
                  value: _simulateError,
                  onChanged: (val) => setState(() => _simulateError = val),
                ),
                const SizedBox(height: 16),
                
                // 2. The tip display (loading, done, and error states)
                if (_state == LoadState.loading)
                  const CircularProgressIndicator()
                else if (_state == LoadState.error)
                  Column(
                    children: [
                      const Text('Failed to load tip.', style: TextStyle(color: Colors.red)),
                      TextButton(
                        onPressed: _getTip,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else if (_state == LoadState.done)
                  Column(
                    children: [
                      Text(_tipText, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      const Text(
                        'Local demo tip, no live AI',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}