import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() {
  runApp(const KameraApp());
}

class KameraApp extends StatelessWidget {
  const KameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamera App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Kamera App')),
        body: const KameraWidget(),
      ),
    );
  }
}

class KameraWidget extends StatefulWidget {
  const KameraWidget({super.key});

  @override
  State<KameraWidget> createState() => _KameraWidgetState();
}

class _KameraWidgetState extends State<KameraWidget> {
  late html.VideoElement _videoElement;

  @override
  void initState() {
    super.initState();
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..style.width = '100%';

    html.window.navigator.mediaDevices
        ?.getUserMedia({'video': true}).then((stream) {
      _videoElement.srcObject = stream;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: undefined_prefixed_name
    return HtmlElementView(viewType: 'videoElement');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ignore: undefined_prefixed_name
    // Registriere das Videoelement für das WebView
    // ignore: undefined_prefixed_name
    // ignore: undefined_prefixed_name
    // ignore:undefined_prefixed_name
    html.ui.platformViewRegistry.registerViewFactory(
      'videoElement',
      (int viewId) => _videoElement,
    );
  }
}