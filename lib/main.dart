import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello World with Calculator')),
        body: const CalculatorWidget(),
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
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  double? _result;

  void _addNumbers() {
    final double num1 = double.tryParse(_controller1.text) ?? 0;
    final double num2 = double.tryParse(_controller2.text) ?? 0;
    setState(() {
      _result = num1 + num2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Hello, World!', style: TextStyle(fontSize: 24)),
          TextField(
            controller: _controller1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter first number'),
          ),
          TextField(
            controller: _controller2,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter second number'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addNumbers,
            child: const Text('Add'),
          ),
          const SizedBox(height: 20),
          if (_result != null)
            Text('Result: $_result', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}