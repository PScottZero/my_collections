import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_collections/components/constants.dart';

class ImageCard extends StatelessWidget {
  final Uint8List image;
  final Widget label;
  final Function() onTap;

  const ImageCard({
    super.key,
    required this.image,
    required this.label,
    required this.onTap,
  });

  DecorationImage? _nullableImage(Uint8List image) => image.isNotEmpty
      ? DecorationImage(
          image: MemoryImage(image),
          fit: BoxFit.cover,
        )
      : null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Constants.imageCardHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: Constants.borderRadius,
          boxShadow: Constants.boxShadow,
          image: _nullableImage(image),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: Constants.padding16,
          decoration: BoxDecoration(
            boxShadow: Constants.boxShadow,
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withAlpha(220),
          ),
          child: label,
        ),
      ),
    );
  }
}
