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
        appBar: AppBar(title: const Text('Bild-Wort-Spiel')),
        body: const WordQuiz(),
      ),
    );
  }
}

class WordQuiz extends StatefulWidget {
  const WordQuiz({super.key});

  @override
  State<WordQuiz> createState() => _WordQuizState();
}

class _WordQuizState extends State<WordQuiz> {
  final TextEditingController _controller = TextEditingController();
  final String _correctWord = 'cat';
  String _feedback = '';

  void _checkAnswer() {
    if (_controller.text.trim().toLowerCase() == _correctWord) {
      setState(() {
        _feedback = '✅ Richtig!';
      });
    } else {
      setState(() {
        _feedback = '❌ Falsch, versuch es nochmal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/81_INF_DIV_SSI.jpg/800px-81_INF_DIV_SSI.jpg',
            height: 200,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Wie heißt das auf Englisch? (3 Buchstaben)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _checkAnswer,
            child: const Text('Prüfen'),
          ),
          const SizedBox(height: 10),
          Text(
            _feedback,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}