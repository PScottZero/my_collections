import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/views/fullscreen_image/fullscreen_image.dart';

class ClickableImage extends StatelessWidget {
  final String image;
  final Uint8List bytes;

  const ClickableImage({super.key, required this.image, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullscreenImage(
            image: image,
            bytes: bytes,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: () {
          if (image.isNotEmpty) {
            return Image.memory(bytes);
          } else {
            return const SimpleText('No Images', center: true);
          }
        }(),
      ),
    );
  }
}
