import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
Future<void> createTableIfNotExists() async {
  const String createTableSql = 'CREATE TABLE IF NOT EXISTS akshay_akshay_users (id serial primary key, email text unique not null, password text not null);';

  final response = await Supabase.instance.client.rpc("execute_sql", params: {"sql": createTableSql}).execute();

  if (response.error != null) {
    throw Exception('Failed to create table: ' + response.error!.message);
  }
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
  final String secretCode = 'akshay';
  final String appName = 'akshay';
  final String usersTable = 'akshay_akshay_users';

  void _showHelloPatrick(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hello Patrick'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Akshay')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello, World!'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showHelloPatrick(context),
                  child: Text('Button 1'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showHelloPatrick(context),
                  child: Text('Button 2'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// === APP_CODE_END ===