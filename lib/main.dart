import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phuc App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Phuc App'),
        ),
        body: const Center(
          child: Text('Hello, Flutter Web! This is Phuc App.'),
        ),
      ),
    );
  }
}