import 'package:flutter/material.dart';
import 'tts/tts_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conditional TTS App',
      home: const TtsPage(),
    );
  }
}

class TtsPage extends StatefulWidget {
  const TtsPage({super.key});

  @override
  State<TtsPage> createState() => _TtsPageState();
}

class _TtsPageState extends State<TtsPage> {
  final TextEditingController _controller = TextEditingController();
  final TextSpeaker _speaker = TextSpeaker();

  void _speak() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _speaker.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speak Word')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speak,
              child: const Text('Speak'),
            ),
          ],
        ),
      ),
    );
  }
}
