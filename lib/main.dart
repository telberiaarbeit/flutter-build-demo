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
      title: 'Hello App',
      home: const HelloPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HelloPage extends StatelessWidget {
  const HelloPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Hello from Supabase!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
// === APP_CODE_END ===