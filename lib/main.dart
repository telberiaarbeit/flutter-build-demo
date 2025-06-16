import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PERSONAL_ACCESS_TOKEN',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PERSONAL_ACCESS_TOKEN'),
        ),
        body: const Center(
          child: Text('Welcome to your new Flutter Web App!'),
        ),
      ),
    );
  }
}