import 'package:flutter/material.dart';

void main() {
  runApp(const Patrick11App());
}

class Patrick11App extends StatelessWidget {
  const Patrick11App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patrick11',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Patrick11'),
        ),
        body: const Center(
          child: Text(
            'Hello, this is the Patrick11 app!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}