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
        appBar: AppBar(title: const Text('Tier-Vokabeltraining')),
        body: const AnimalQuizGrid(),
      ),
    );
  }
}

class AnimalQuizGrid extends StatelessWidget {
  const AnimalQuizGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        AnimalQuizCard(name: 'Eidechse', emoji: '🦎', solution: 'eidechse'),
        AnimalQuizCard(name: 'Wellensittich', emoji: '🐦', solution: 'wellensittich'),
        AnimalQuizCard(name: 'Chinchilla', emoji: '🐹', solution: 'chinchilla'),
        AnimalQuizCard(name: 'Fuchs', emoji: '🦊', solution: 'fuchs'),
      ],
    );
  }
}

class AnimalQuizCard extends StatefulWidget {
  final String name;
  final String emoji;
  final String solution;

  const AnimalQuizCard({required this.name, required this.emoji, required this.solution, super.key});

  @override
  State<AnimalQuizCard> createState() => _AnimalQuizCardState();
}

class _AnimalQuizCardState extends State<AnimalQuizCard> {
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';

  void _checkAnswer() {
    final input = _controller.text.trim().toLowerCase();
    setState(() {
      _feedback = input == widget.solution ? '✅' : '❌';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Wie heißt das Tier?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Prüfen'),
            ),
            Text(_feedback, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}