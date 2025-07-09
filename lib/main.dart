// Supabase credentials (do not modify)
const supabaseUrl = 'https://ovnhubsupkhesugfrrsv.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await setupDatabase();
  runApp(const MyApp());
}

// === SETUP_DB_START ===
Future<void> setupDatabase() async {
  final List<String> createTableSqls = [
    '''
    CREATE TABLE IF NOT EXISTS luke_todo_app_tasks (
      id serial primary key,
      title text,
      is_complete boolean default false
    );
    '''
  ];

  for (final sql in createTableSqls) {
    await Supabase.instance.client.rpc('execute_sql', params: {'sql': sql});
  }
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
final String tasksTable = 'luke_todo_app_tasks';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      home: const TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final response = await Supabase.instance.client.from(tasksTable).select();
    setState(() {
      _tasks = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) return;
    await Supabase.instance.client.from(tasksTable).insert({'title': title});
    _controller.clear();n    _loadTasks();
  }

  Future<void> _toggleComplete(int id, bool currentStatus) async {
    await Supabase.instance.client
        .from(tasksTable)
        .update({'is_complete': !currentStatus})
        .eq('id', id);
    _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await Supabase.instance.client.from(tasksTable).delete().eq('id', id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter task'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(_controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _tasks.map((task) {
                return ListTile(
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      decoration: task['is_complete']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: task['is_complete'],
                    onChanged: (_) => _toggleComplete(task['id'], task['is_complete']),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task['id']),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
// === APP_CODE_END ===