import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://ovnhubsupkhesugfrrsv.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';


// === SETUP_DB_START ===
const List<String> createTableSqls = [
  '''
  CREATE TABLE IF NOT EXISTS hoang_hello_app_users (
    id serial primary key,
    email text unique not null,
    password text not null
  );
  '''
];
// === SETUP_DB_END ===

// === APP_CODE_START ===

final String usersTable = 'hoang_hello_app_users';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await setupDatabase();
  runApp(const MyApp());
}

Future<void> setupDatabase() async {
  final client = Supabase.instance.client;
  for (final sql in createTableSqls) {
    try {
      final result = await client.rpc('execute_sql', params: {'sql': sql});
      print('SQL executed successfully: ' + result.toString());
    } catch (e) {
      print('Error executing SQL: ' + e.toString());
    }
  }

  // Optional: Try to select from the table to confirm it exists
  try {
    final res = await client.from('hoang_hello_app_users').select().limit(1);
    print('Table exists! Query result: ' + res.toString());
  } catch (e) {
    print('Table does not exist or query failed: ' + e.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello App Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _message;

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final res = await Supabase.instance.client
        .from(usersTable)
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

    setState(() {
      _message = res != null ? 'Login successful!' : 'Invalid credentials';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(_message!, style: const TextStyle(color: Colors.red))
            ]
          ],
        ),
      ),
    );
  }
}
// === APP_CODE_END ===