// === SETUP_DB_START ===
/*
  GPT: Insert DB setup code here.
  Use placeholders like {{TABLE_NAME_1}}, {{COLUMNS_SQL_1}} for easy replacement.
*/
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// Placeholders for GPT to replace:
const List<String> createTableSqls = [
  '''
  CREATE TABLE IF NOT EXISTS {{TABLE_NAME_1}} (
    {{COLUMNS_SQL_1}}
  );
  ''',
  '''
  CREATE TABLE IF NOT EXISTS {{TABLE_NAME_2}} (
    {{COLUMNS_SQL_2}}
  );
  '''
];

Future<void> setupDatabase() async {
  for (final sql in createTableSqls) {
    final uri = Uri.parse(' [36m$supabaseUrl/rest/v1/rpc/execute_sql [0m');
    final response = await http.post(
      uri,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'sql': sql}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to ensure table exists:  [31m${response.body} [0m');
    }
  }
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
/*
  GPT: Insert main app code here.
  Example: Flutter widgets, CRUD logic, etc.
  This is the main app entry point.
*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  await setupDatabase(); // Run DB setup before app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Table Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(child: Text('Replace this with your app UI!')),
      ),
    );
  }
}
// === APP_CODE_END ===