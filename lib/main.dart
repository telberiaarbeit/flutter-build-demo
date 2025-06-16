import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

enum Filter { all, done, notDone }

class _ToDoAppState extends State<ToDoApp> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  Filter _currentFilter = Filter.all;
  bool _showFireworks = false;

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
        _showFireworks = true;
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _showFireworks = false;
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
            appBar: AppBar(title: const Text('Meine ToDo App')),
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
          if (_showFireworks)
            Center(
              child: Lottie.network(
                'https://assets1.lottiefiles.com/packages/lf20_cukzrbrg.json',
                width: 200,
              ),
            ),
        ],
      ),
    );
  }
}