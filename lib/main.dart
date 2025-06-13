import 'package:flutter/material.dart';

void main() {
  runApp(const News1App());
}

class News1App extends StatelessWidget {
  const News1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News1',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('News1'),
        ),
        body: const Center(
          child: Text(
            'Welcome to News1!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}