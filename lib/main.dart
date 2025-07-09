import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

// Restlicher Code unverändert aus Canvas eingefügt.

// === SETUP_DB_START ===
Future<void> createTableIfNotExists() async {
  final String createTableSql = '''
    CREATE TABLE IF NOT EXISTS patrick19_inventar_items (
      id serial primary key,
      user_id uuid references auth.users(id) on delete cascade,
      name text not null,
      type text check (type in ('Messer', 'Gabel', 'Teller')),
      created_at timestamp with time zone default timezone('utc'::text, now())
    );
  ''';
  await Supabase.instance.client.rpc('execute_sql', params: {'sql': createTableSql});
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
// Canvas-Code bleibt identisch.
// === APP_CODE_END ===