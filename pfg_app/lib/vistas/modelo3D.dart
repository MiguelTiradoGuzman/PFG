import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Pantalla para mostrar un Modelo 3D en pantalla.
class Modelo3D extends StatelessWidget {
  // URL del modelo 3d
  final String urlModelo;
  // Lugar de interés del modelo 3D
  final LugarInteres lugar;

  const Modelo3D({super.key, required this.urlModelo, required this.lugar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Model Viewer')),
        body: ModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          src: urlModelo,
          alt: lugar.getNombre,
          ar: true,
          autoRotate: true,
          iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
          disableZoom: true,
        ),
      ),
    );
  }
}
