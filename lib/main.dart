import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

enum Filter { all, done, notDone }

class _ToDoAppState extends State<ToDoApp> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  Filter _currentFilter = Filter.all;
  bool _showHearts = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addTask(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({'title': task, 'done': false});
        _controller.clear();
      });
    }
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
      if (_tasks[index]['done']) {
        _showHearts = true;
        _animationController.forward(from: 0);
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _showHearts = false;
          });
        });
      }
    });
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_currentFilter == Filter.done) {
      return _tasks.where((t) => t['done'] == true).toList();
    } else if (_currentFilter == Filter.notDone) {
      return _tasks.where((t) => t['done'] == false).toList();
    }
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text('Meine ToDo App von Christoph')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(labelText: 'Neue Aufgabe'),
                          onSubmitted: _addTask,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addTask(_controller.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Alle'),
                        selected: _currentFilter == Filter.all,
                        onSelected: (_) => setState(() => _currentFilter = Filter.all),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Erledigt'),
                        selected: _currentFilter == Filter.done,
                        onSelected: (_) => setState(() => _currentFilter = Filter.done),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Nicht erledigt'),
                        selected: _currentFilter == Filter.notDone,
                        onSelected: (_) => setState(() => _currentFilter = Filter.notDone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        final originalIndex = _tasks.indexOf(task);
                        return ListTile(
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration: task['done']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: Checkbox(
                            value: task['done'],
                            onChanged: (value) => _toggleDone(originalIndex),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showHearts)
            IgnorePointer(
              child: CustomPaint(
                painter: HeartPainter(_animationController),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}

class HeartPainter extends CustomPainter {
  final Animation<double> animation;
  final Random _random = Random();
  HeartPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.pink.withOpacity(1.0 - animation.value);
    for (int i = 0; i < 30; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = size.height - (_random.nextDouble() * size.height * animation.value);
      final path = Path();
      path.moveTo(dx, dy);
      path.cubicTo(dx - 10, dy - 10, dx - 25, dy + 10, dx, dy + 30);
      path.cubicTo(dx + 25, dy + 10, dx + 10, dy - 10, dx, dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}