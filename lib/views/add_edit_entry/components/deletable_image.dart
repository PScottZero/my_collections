import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_collections/constants.dart';

class DeletableImage extends StatelessWidget {
  final Uint8List image;
  final Function() onDelete;

  const DeletableImage({
    super.key,
    required this.image,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: Constants.borderRadius,
          child: Image.memory(image),
        ),
        IconButton(
          color: Colors.red,
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}
