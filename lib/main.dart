import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
Future<void> createTableIfNotExists() async {
  final String createTableSql = '''
    CREATE TABLE IF NOT EXISTS hoang_hello_minh_users (
      id serial primary key,
      name text
    );
  ''';

  await Supabase.instance.client.rpc('execute_sql', params: {'sql': createTableSql});
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  await createTableIfNotExists();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Minh App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello Minh')),
        body: const Center(child: Text('Hello, Minh!')),
      ),
    );
  }
}
// === APP_CODE_END ===