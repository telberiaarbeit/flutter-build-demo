import 'package:flutter/material.dart';

void main() {
  runApp(const HelloPicasoApp());
}

class HelloPicasoApp extends StatelessWidget {
  const HelloPicasoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Picaso',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello Picaso'),
        ),
        body: const Center(
          child: Text(
            'Welcome to Hello Picaso!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}