import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageRevealApp(),
    );
  }
}

class ImageRevealApp extends StatefulWidget {
  const ImageRevealApp({super.key});

  @override
  State<ImageRevealApp> createState() => _ImageRevealAppState();
}

class _ImageRevealAppState extends State<ImageRevealApp> {
  Uint8List? originalBytes;
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  Offset? cursorPosition;

  void pickImage() {
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            originalBytes = reader.result as Uint8List;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Reveal App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: pickImage, child: const Text('Upload Image')),
            const SizedBox(height: 20),
            if (originalBytes != null)
              MouseRegion(
                onHover: (event) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  setState(() {
                    cursorPosition = box.globalToLocal(event.position);
                  });
                },
                child: Stack(
                  children: [
                    Image.memory(originalBytes!),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    if (cursorPosition != null)
                      Positioned(
                        left: cursorPosition!.dx - 50,
                        top: cursorPosition!.dy - 50,
                        child: ClipOval(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.memory(originalBytes!),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}