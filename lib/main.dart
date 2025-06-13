import 'package:flutter/material.dart';

void main() {
  runApp(const ColorSwitcherApp());
}

class ColorSwitcherApp extends StatelessWidget {
  const ColorSwitcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ColorSwitcher(),
    );
  }
}

class ColorSwitcher extends StatefulWidget {
  const ColorSwitcher({super.key});

  @override
  State<ColorSwitcher> createState() => _ColorSwitcherState();
}

class _ColorSwitcherState extends State<ColorSwitcher> {
  Color _backgroundColor = Colors.white;

  void _changeColor(Color color) {
    setState(() {
      _backgroundColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(title: const Text('Farbschalter')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _changeColor(Colors.green),
              child: const Text('Grün'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => _changeColor(Colors.black),
              child: const Text('Schwarz'),
            ),
          ],
        ),
      ),
    );
  }
} 