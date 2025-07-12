import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const supabaseUrl = 'https://sjzsfysybiimifmevogx.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqenNmeXN5YmlpbWlmbWV2b2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0Njg2NjUsImV4cCI6MjA2NTA0NDY2NX0.Td9-TLFTolrrddEIlJw7GMf235eCR2oGQGwSFUJDxTY';

// === SETUP_DB_START ===
const String createTableSql = '''
CREATE TABLE IF NOT EXISTS patrick11_zeiterfassung_projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  client TEXT,
  description TEXT
);

CREATE TABLE IF NOT EXISTS patrick11_zeiterfassung_timelogs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT,
  duration_minutes INTEGER,
  FOREIGN KEY (project_id) REFERENCES patrick11_zeiterfassung_projects(id)
);
''';
// === SETUP_DB_END ===

// === APP_CODE_START ===
class Project {
  final int? id;
  final String name;
  final String? client;
  final String? description;

  Project({this.id, required this.name, this.client, this.description});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'client': client,
        'description': description,
      };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'],
        name: map['name'],
        client: map['client'],
        description: map['description'],
      );
}

class TimeLog {
  final int? id;
  final int projectId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;

  TimeLog({this.id, required this.projectId, required this.startTime, this.endTime, this.durationMinutes});

  Map<String, dynamic> toMap() => {
        'id': id,
        'project_id': projectId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'duration_minutes': durationMinutes,
      };

  factory TimeLog.fromMap(Map<String, dynamic> map) => TimeLog(
        id: map['id'],
        projectId: map['project_id'],
        startTime: DateTime.parse(map['start_time']),
        endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
        durationMinutes: map['duration_minutes'],
      );
}

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'zeiterfassung.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(createTableSql);
      },
    );
    return _db!;
  }

  static Future<void> insertProject(Project project) async {
    final db = await database;
    await db.insert('patrick11_zeiterfassung_projects', project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Project>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patrick11_zeiterfassung_projects');
    return maps.map((e) => Project.fromMap(e)).toList();
  }

  static Future<void> deleteProject(int id) async {
    final db = await database;
    await db.delete('patrick11_zeiterfassung_projects', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> insertTimeLog(TimeLog log) async {
    final db = await database;
    await db.insert('patrick11_zeiterfassung_timelogs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<TimeLog>> getAllTimeLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patrick11_zeiterfassung_timelogs', orderBy: 'start_time DESC');
    return maps.map((e) => TimeLog.fromMap(e)).toList();
  }

  static Future<void> deleteTimeLog(int id) async {
    final db = await database;
    await db.delete('patrick11_zeiterfassung_timelogs', where: 'id = ?', whereArgs: [id]);
  }
}

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  return await DatabaseService.getAllProjects();
});

final timeLogsProvider = FutureProvider<List<TimeLog>>((ref) async {
  return await DatabaseService.getAllTimeLogs();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeiterfassung',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimeTrackingScreen(),
    );
  }
}

class TimeTrackingScreen extends ConsumerStatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  ConsumerState<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends ConsumerState<TimeTrackingScreen> {
  Project? selectedProject;
  DateTime? startTime;

  void startTimer() {
    setState(() {
      startTime = DateTime.now();
    });
  }

  Future<void> stopTimer() async {
    final endTime = DateTime.now();
    if (selectedProject != null && startTime != null) {
      final duration = endTime.difference(startTime!).inMinutes;
      final log = TimeLog(
        projectId: selectedProject!.id!,
        startTime: startTime!,
        endTime: endTime,
        durationMinutes: duration,
      );
      await DatabaseService.insertTimeLog(log);
      ref.refresh(timeLogsProvider);
    }
    setState(() {
      startTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final timeLogs = ref.watch(timeLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zeit erfassen')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: projects.when(
              data: (items) => DropdownButton<Project>(
                isExpanded: true,
                value: selectedProject,
                hint: const Text('Projekt wählen'),
                items: items.map((project) {
                  return DropdownMenuItem<Project>(
                    value: project,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedProject = value),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Fehler: $e'),
            ),
          ),
          ElevatedButton(
            onPressed: startTime == null ? startTimer : stopTimer,
            child: Text(startTime == null ? 'Start' : 'Stop'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text('Erfasste Zeiten', style: TextStyle(fontSize: 18)),
          Expanded(
            child: timeLogs.when(
              data: (items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final log = items[index];
                  return Dismissible(
                    key: ValueKey(log.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
                      await DatabaseService.deleteTimeLog(log.id!);
                      ref.refresh(timeLogsProvider);
                    },
                    child: ListTile(
                      title: Text('Projekt-ID: ${log.projectId}'),
                      subtitle: Text(
                        '${DateFormat.yMd().add_Hm().format(log.startTime)} - ${log.endTime != null ? DateFormat.Hm().format(log.endTime!) : 'läuft...'} (${log.durationMinutes ?? '-'} min)',
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fehler: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
// === APP_CODE_END ===