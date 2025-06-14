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
        body: Center(
          child: Text(
            'WORK NOW 2',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}