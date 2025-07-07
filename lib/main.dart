// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App Hello')),
        body: Center(
          child: Text(
            'Minh test',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}