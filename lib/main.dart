import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
const String createTableSql = '''
  CREATE TABLE IF NOT EXISTS hoang_todo_tasks (
    id serial primary key,
    title text not null,
    is_done boolean not null default false,
    created_at timestamp with time zone default timezone('utc', now())
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
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const TodoHomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  Future<void> login() async {
    final email = emailController.text;
    final password = passwordController.text;
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      setState(() => error = 'Login failed');
    }
  }

  Future<void> signup() async {
    final email = emailController.text;
    final password = passwordController.text;
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      setState(() => error = 'Signup failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: login, child: const Text('Login')),
            TextButton(onPressed: signup, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  final String tasksTable = 'hoang_todo_tasks';
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final response = await Supabase.instance.client
        .from(tasksTable)
        .select()
        .order('created_at', ascending: false);
    setState(() {
      tasks = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addTask(String title) async {
    if (title.isEmpty) return;
    await Supabase.instance.client.from(tasksTable).insert({'title': title});
    _controller.clear();
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await Supabase.instance.client.from(tasksTable).delete().match({'id': id});
    fetchTasks();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'New task'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask(_controller.text),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['title']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTask(task['id']),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
// === APP_CODE_END ===