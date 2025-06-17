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
        backgroundColor: Colors.lightBlueAccent,
        body: const Center(
          child: HoverText(),
        ),
      ),
    );
  }
}

class HoverText extends StatefulWidget {
  const HoverText({super.key});

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: _isHovered ? 40 : 32,
          color: _isHovered ? Colors.yellowAccent : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        child: const Text('Hello World, Patrick!'),
      ),
    );
  }
}