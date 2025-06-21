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
        appBar: AppBar(title: const Text('Tiere Icons')),
        body: const AnimalIcons(),
      ),
    );
  }
}

class AnimalIcons extends StatelessWidget {
  const AnimalIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        AnimalCard(name: 'Eidechse', emoji: '🦎'),
        AnimalCard(name: 'Wellensittich', emoji: '🐦'),
        AnimalCard(name: 'Chinchilla', emoji: '🐹'),
        AnimalCard(name: 'Fuchs', emoji: '🦊'),
      ],
    );
  }
}

class AnimalCard extends StatelessWidget {
  final String name;
  final String emoji;

  const AnimalCard({required this.name, required this.emoji, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}