import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _handleButtonPress(String label) {
    print('Button "$label" pressed!');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello World App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Hello World!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleButtonPress('Button 1'),
                child: const Text('Button 1'),
              ),
              ElevatedButton(
                onPressed: () => _handleButtonPress('Button 2'),
                child: const Text('Button 2'),
              ),
              ElevatedButton(
                onPressed: () => _handleButtonPress('Button 3'),
                child: const Text('Button 3'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}