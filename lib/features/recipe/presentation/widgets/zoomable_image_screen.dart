import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ZoomableImageScreen extends StatefulWidget {
  final String imageUrl;

  const ZoomableImageScreen({super.key, required this.imageUrl});

  @override
  State<ZoomableImageScreen> createState() => _ZoomableImageScreenState();
}

class _ZoomableImageScreenState extends State<ZoomableImageScreen> {
  @override
  Widget build(BuildContext context) {
    final isNetwork = widget.imageUrl.startsWith('http');
    final imageWidget = isNetwork
        ? Image.network(widget.imageUrl, fit: BoxFit.contain)
        : Image.file(File(widget.imageUrl), fit: BoxFit.contain);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.5,
          maxScale: 4.0,

          scaleEnabled: true,

          child: imageWidget,
        ),
      ),
    );
  }
}
