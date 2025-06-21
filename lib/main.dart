import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Word Speaker',
      home: const WordSpeakerPage(),
    );
  }
}

class WordSpeakerPage extends StatefulWidget {
  const WordSpeakerPage({super.key});

  @override
  State<WordSpeakerPage> createState() => _WordSpeakerPageState();
}

class _WordSpeakerPageState extends State<WordSpeakerPage> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speak() async {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speak English Word')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter an English word',
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