import 'package:flutter/material.dart';
import 'tts_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocab Speaker',
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
      appBar: AppBar(title: const Text('Vocab Speaker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter vocabulary word',
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

// tts_interface.dart
export 'tts_web.dart'
    if (dart.library.io) 'tts_mobile.dart';

// tts_mobile.dart
import 'package:flutter_tts/flutter_tts.dart';

class TextSpeaker {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.speak(text);
  }
}

// tts_web.dart
import 'dart:html';

class TextSpeaker {
  Future<void> speak(String text) async {
    final synth = window.speechSynthesis;
    final utterance = SpeechSynthesisUtterance(text);
    utterance.lang = 'en-US';
    synth.cancel();
    synth.speak(utterance);
  }
}