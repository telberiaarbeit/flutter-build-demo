import 'package:flutter/material.dart';

void main() {
  runApp(const Testing1App());
}

class Testing1App extends StatelessWidget {
  const Testing1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TESTING1 APP',
      home: Scaffold(
        appBar: AppBar(title: const Text('TESTING1 APP')),
        body: const Center(
          child: Text(
            'Hello from TESTING1 APP!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}