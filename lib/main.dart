import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
const String createTableSql = '''
  CREATE TABLE IF NOT EXISTS hoang_demo_users (
    id serial primary key,
    email text unique not null,
    password text not null
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String usersTable = 'hoang_demo_users';
  String _message = '';

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await Supabase.instance.client
        .from(usersTable)
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

    if (response != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(email: email)),
      );
    } else {
      setState(() {
        _message = 'Invalid credentials';
      });
    }
  }

  Future<void> _signup() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await Supabase.instance.client.from(usersTable).insert({
        'email': email,
        'password': password,
      });
      setState(() => _message = 'User registered!');
    } catch (e) {
      setState(() => _message = 'Sign up failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(onPressed: _signup, child: Text('Sign Up')),
            SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String email;

  const HomePage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as: ' + email, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
// === APP_CODE_END ===