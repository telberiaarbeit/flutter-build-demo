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
          title: const Text('News1 - Updated'),
        ),
        body: const Center(
          child: Text(
            'Breaking News: The News1 App just got updated!',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}