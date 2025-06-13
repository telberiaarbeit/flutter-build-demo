import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Wait Response',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Wait Response'),
        ),
        body: const Center(
          child: Text('Hello, Flutter Web!'),
        ),
      ),
    );
  }
}