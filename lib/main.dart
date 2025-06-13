import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CursorFollower(),
    );
  }
}

class CursorFollower extends StatefulWidget {
  const CursorFollower({super.key});

  @override
  State<CursorFollower> createState() => _CursorFollowerState();
}

class _CursorFollowerState extends State<CursorFollower> {
  Offset _cursorOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _cursorOffset = event.position;
          });
        },
        child: Stack(
          children: [
            const Center(child: Text('Move your mouse around!')),
            Positioned(
              left: _cursorOffset.dx,
              top: _cursorOffset.dy,
              child: const Text('👀', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }
}