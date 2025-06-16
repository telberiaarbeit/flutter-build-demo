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
  Offset? _donkeyPosition;

  void _pickImage() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        await reader.onLoad.first;
        setState(() {
          _uploadedImage = reader.result as Uint8List;
          _donkeyPosition = null; // Reset position on new image
        });
      }
    });
  }

  void _setDonkeyPosition(TapUpDetails details, BuildContext context, double imageWidth) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final scaleFactor = imageWidth / box.size.width;
    setState(() {
      _donkeyPosition = localPosition * scaleFactor;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double displayWidth = 300;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Eselkopf Ersetzer')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Bild hochladen'),
              ),
              const SizedBox(height: 20),
              if (_uploadedImage != null)
                GestureDetector(
                  onTapUp: (details) => _setDonkeyPosition(details, context, displayWidth),
                  child: Stack(
                    children: [
                      Image.memory(
                        _uploadedImage!,
                        width: displayWidth,
                      ),
                      if (_donkeyPosition != null)
                        Positioned(
                          left: _donkeyPosition!.dx - 50,
                          top: _donkeyPosition!.dy - 50,
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Donkey_cartoon.svg/240px-Donkey_cartoon.svg.png',
                            width: 100,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}