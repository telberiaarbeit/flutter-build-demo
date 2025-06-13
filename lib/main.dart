import 'package:flutter/material.dart';

void main() {
  runApp(const Patrick10App());
}

class Patrick10App extends StatelessWidget {
  const Patrick10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patrick10',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Patrick10'),
        ),
        body: const Center(
          child: Text(
            'Hello, this is the Patrick10 app!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}