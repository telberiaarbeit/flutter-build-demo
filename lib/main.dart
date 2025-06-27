import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() {
  runApp(const InventarApp());
}

class InventarApp extends StatelessWidget {
  const InventarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventar App',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _imageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  void _pickImage() {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((event) {
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

  void _submitItem() {
    String name = _nameController.text;
    String tags = _tagsController.text;
    print('Item: $name, Tags: $tags');
    // Hier kannst du Daten speichern oder weiterverarbeiten
    setState(() {
      _imageUrl = null;
      _nameController.clear();
      _tagsController.clear();
    });
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (_imageUrl != null) Image.network(_imageUrl!),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _tagsController,
          decoration: const InputDecoration(labelText: 'Hashtags (z. B. #schraube, #gewindestange)'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _submitItem, child: const Text('Speichern')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventar App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Add Item'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Remove Item'),
              ),
              const SizedBox(height: 20),
              if (_imageUrl != null) _buildForm(),
            ],
          ),
        ),
      ),
    );
  }
}