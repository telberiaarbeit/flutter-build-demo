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
        appBar: AppBar(title: const Text('Hoang4')),
        body: const Center(
          child: Text('Welcome to the Hoang4 app!'),
        ),
      ),
    );
  }
}