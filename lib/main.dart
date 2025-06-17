import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Login')),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Username',
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const TodoApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(child: Text('Welcome! Loading your ToDo app...', style: TextStyle(fontSize: 18))),
    );
  }
}

class TodoItem {
  String title;
  bool completed;

  TodoItem(this.title, {this.completed = false});
}

enum FilterOption { all, completed, active }

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<TodoItem> _todos = [];
  final TextEditingController _todoController = TextEditingController();
  FilterOption _filter = FilterOption.all;
  String? _imageUrl;

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todos.add(TodoItem(_todoController.text));
        _todoController.clear();
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].completed = !_todos[index].completed;
    });
  }

  void _pickImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.capture = 'environment';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _imageUrl = reader.result as String;
          });
        });
      }
    });
  }

  List<TodoItem> get _filteredTodos {
    switch (_filter) {
      case FilterOption.completed:
        return _todos.where((todo) => todo.completed).toList();
      case FilterOption.active:
        return _todos.where((todo) => !todo.completed).toList();
      case FilterOption.all:
      default:
        return _todos;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Patrick ToDo'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.camera),
              onPressed: _pickImage,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.slider_horizontal_3),
              onPressed: () => showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: const Text('Filter wählen'),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () => setState(() => _filter = FilterOption.all),
                      child: const Text('Alle'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => setState(() => _filter = FilterOption.completed),
                      child: const Text('Erledigt'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => setState(() => _filter = FilterOption.active),
                      child: const Text('Offen'),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_imageUrl != null) Image.network(_imageUrl!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _todoController,
                      placeholder: 'Neue Aufgabe',
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    child: const Icon(CupertinoIcons.add),
                    onPressed: _addTodo,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = _filteredTodos[index];
                  return CupertinoListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: todo.completed,
                      onChanged: (_) => _toggleTodo(_todos.indexOf(todo)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  const CupertinoListTile({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [title, if (trailing != null) trailing!],
      ),
    );
  }
}