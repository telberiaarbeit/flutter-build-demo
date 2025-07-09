import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
const String createTableSql = '''
  CREATE TABLE IF NOT EXISTS luke_task_app_tasks (
    id serial primary key,
    title text not null,
    is_complete boolean default false,
    due_date date,
    priority text
  );
''';

Future<void> createTableIfNotExists() async {
  await Supabase.instance.client.rpc('execute_sql', params: {'sql': createTableSql});
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await createTableIfNotExists();
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      home: TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final String tasksTable = 'luke_task_app_tasks';
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final res = await Supabase.instance.client.from(tasksTable).select('*').order('id');
    setState(() {
      _tasks = List<Map<String, dynamic>>.from(res);
    });
  }

  Future<void> _addTask(String title) async {
    if (title.isEmpty) return;
    await Supabase.instance.client.from(tasksTable).insert({'title': title});
    _controller.clear();
    await _loadTasks();
  }

  Future<void> _toggleComplete(int id, bool isComplete) async {
    await Supabase.instance.client.from(tasksTable).update({'is_complete': !isComplete}).eq('id', id);
    await _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await Supabase.instance.client.from(tasksTable).delete().eq('id', id);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter task title'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addTask(_controller.text),
                )
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
                      decoration: task['is_complete'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task['is_complete'],
                    onChanged: (_) => _toggleComplete(task['id'], task['is_complete']),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
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