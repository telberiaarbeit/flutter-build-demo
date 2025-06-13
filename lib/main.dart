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
      debugShowCheckedModeBanner: false,
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
  Offset _cursorOffset = Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return MouseRegion(
            onHover: (event) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(event.position);
              setState(() {
                _cursorOffset = localPosition;
              });
            },
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.lightBlue[50],
                  child: const Center(
                    child: Text(
                      'Move your mouse around the screen!',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Positioned(
                  left: _cursorOffset.dx,
                  top: _cursorOffset.dy,
                  child: Column(
                    children: [
                      const Text('👀', style: TextStyle(fontSize: 40)),
                      Text(
                        '(${_cursorOffset.dx.toStringAsFixed(0)}, ${_cursorOffset.dy.toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}