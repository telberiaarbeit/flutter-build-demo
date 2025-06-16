import 'package:flutter/material.dart';

void main() {
  runApp(const NewApp1());
}

class NewApp1 extends StatelessWidget {
  const NewApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New App1',
      home: Scaffold(
        appBar: AppBar(title: const Text('New App1')),
        body: const Center(
          child: Text(
            'Welcome to New App1!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}