import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

void main() {
  runApp(const DonkeyFaceApp());
}

class DonkeyFaceApp extends StatefulWidget {
  const DonkeyFaceApp({super.key});

  @override
  State<DonkeyFaceApp> createState() => _DonkeyFaceAppState();
}

class _DonkeyFaceAppState extends State<DonkeyFaceApp> {
  Uint8List? _uploadedImage;

  void _pickImage() {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _uploadedImage = reader.result as Uint8List;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Eselkopf Ersetzer')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Bild hochladen',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_uploadedImage != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.memory(_uploadedImage!, width: 300),
                    Positioned(
                      top: 60,
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Donkey_cartoon.svg/240px-Donkey_cartoon.svg.png',
                        width: 100,
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}