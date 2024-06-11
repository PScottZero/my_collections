import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/models/mc_local_storage.dart';

class FullscreenImage extends StatelessWidget {
  final String image;
  final Uint8List bytes;

  const FullscreenImage({super.key, required this.image, required this.bytes});

  Future<void> _downloadImage(BuildContext context) async {
    await MCLocalStorage.downloadImage(image, bytes);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SimpleText("Downloaded $image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(200),
        actions: [
          IconButton(
            onPressed: () => _downloadImage(context),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: Container(
          alignment: Alignment.center,
          child: Image.memory(bytes),
        ),
      ),
    );
  }
}
