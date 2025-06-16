import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello 2',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello 2'),
        ),
        body: const Center(
          child: Text('Hello, Flutter Web!'),
        ),
      ),
    );
  }
}