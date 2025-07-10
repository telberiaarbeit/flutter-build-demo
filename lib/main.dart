import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
const String createTableSql = '''
  CREATE TABLE IF NOT EXISTS hoang_my_app_test_users (
    id serial primary key,
    email text unique not null,
    password text not null
  );
''';

Future<void> createTableIfNotExists() async {
  final client = Supabase.instance.client;
  await client.rpc('execute_sql', params: {'sql': createTableSql});
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await createTableIfNotExists();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';

  final String usersTable = 'hoang_my_app_test_users';

  Future<void> signUp() async {
    final email = emailController.text;
    final password = passwordController.text;
    final existing = await Supabase.instance.client
        .from(usersTable)
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      setState(() => message = 'Email đã tồn tại');
      return;
    }

    await Supabase.instance.client.from(usersTable).insert({
      'email': email,
      'password': password,
    });

    setState(() => message = 'Đăng ký thành công!');
  }

  Future<void> login() async {
    final email = emailController.text;
    final password = passwordController.text;

    final user = await Supabase.instance.client
        .from(usersTable)
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

    setState(() => message =
        user != null ? 'Đăng nhập thành công!' : 'Sai thông tin đăng nhập');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: const Text('Đăng ký')),
            ElevatedButton(onPressed: login, child: const Text('Đăng nhập')),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
// === APP_CODE_END ===