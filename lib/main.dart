import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  void _login() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            width: 375,
            height: 812,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: _isLoggedIn ? const CalculatorWidget() : LoginRegisterScreen(onLogin: _login),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginRegisterScreen extends StatelessWidget {
  final VoidCallback onLogin;
  const LoginRegisterScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onLogin,
            child: const Text('Login'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = '';
  String _result = '';

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _evaluate(_display);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _display += value;
      }
    });
  }

  String _evaluate(String expression) {
    try {
      final result = double.parse(_calculate(expression));
      return result.toString();
    } catch (_) {
      return 'Error';
    }
  }

  String _calculate(String expr) {
    expr = expr.replaceAll('x', '*');
    expr = expr.replaceAll('÷', '/');
    final exp = expr.replaceAllMapped(
        RegExp(r'(?<=\d)([+\-*/])(?=\d)'),
        (Match m) => ' ${m.group(0)} ');
    final parts = exp.split(' ');
    double total = double.parse(parts[0]);
    for (int i = 1; i < parts.length; i += 2) {
      String op = parts[i];
      double num = double.parse(parts[i + 1]);
      if (op == '+') total += num;
      if (op == '-') total -= num;
      if (op == '*') total *= num;
      if (op == '/') total /= num;
    }
    return total.toString();
  }

  Widget _buildButton(String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onPressed(value),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.blueGrey.shade50,
            foregroundColor: Colors.black,
          ),
          child: Text(value, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Text('Hello, World!', style: TextStyle(fontSize: 24)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_display, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(_result, style: const TextStyle(fontSize: 24, color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('/')]),
              Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('x')]),
              Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('-')]),
              Row(children: [_buildButton('0'), _buildButton('.'), _buildButton('='), _buildButton('+')]),
              Row(children: [_buildButton('C')]),
            ],
          ),
        ),
      ],
    );
  }
}