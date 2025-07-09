import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

void main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

// === SETUP_DB_START ===
Future<void> createTableIfNotExists() async {
  final String createTableSql = '''
    CREATE TABLE IF NOT EXISTS patrick19_inventar_items (
      id serial primary key,
      name text not null,
      type text check (type in ('Messer', 'Gabel', 'Teller')),
      created_at timestamp with time zone default timezone('utc'::text, now())
    );
  ''';
  await Supabase.instance.client.rpc('execute_sql', params: {'sql': createTableSql});
}
// === SETUP_DB_END ===

// === APP_CODE_START ===
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String itemsTable = 'patrick19_inventar_items';
  final TextEditingController nameController = TextEditingController();
  String selectedType = 'Messer';
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    createTableIfNotExists().then((_) => fetchItems());
  }

  Future<void> fetchItems() async {
    final response = await Supabase.instance.client.from(itemsTable).select();
    setState(() {
      items = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> addItem() async {
    if (items.length >= 3) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    await Supabase.instance.client.from(itemsTable).insert({
      'name': name,
      'type': selectedType,
    });
    nameController.clear();
    fetchItems();
  }

  Future<void> deleteItem(int id) async {
    await Supabase.instance.client.from(itemsTable).delete().eq('id', id);
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Inventar verwalten')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Gegenstandsname'),
              ),
              DropdownButton<String>(
                value: selectedType,
                items: ['Messer', 'Gabel', 'Teller']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              ElevatedButton(
                onPressed: items.length < 3 ? addItem : null,
                child: const Text('Hinzufügen'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(item['type']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteItem(item['id']),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// === APP_CODE_END ===