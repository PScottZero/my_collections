import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_collections/components/rounded_button.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:provider/provider.dart';

class ThumbnailChooser extends StatelessWidget {
  final Uint8List thumbnail;
  final Function(Uint8List) onThumbnailUpload;

  const ThumbnailChooser({
    super.key,
    required this.thumbnail,
    required this.onThumbnailUpload,
  });

  void _addThumbnail(MCModel model) async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (image != null) {
      onThumbnailUpload(await image.readAsBytes());
    }
  }

  DecorationImage? _nullableImage(Uint8List image) => image.isNotEmpty
      ? DecorationImage(image: MemoryImage(image), fit: BoxFit.cover)
      : null;

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) => Column(
        children: [
          Column(
            children: [
              Container(
                height: Constants.thumbnailHeight,
                decoration: BoxDecoration(
                  borderRadius: Constants.borderRadius,
                  image: _nullableImage(thumbnail),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: IfElse(
                  condition: thumbnail.isEmpty,
                  ifWidget: () => const SimpleText('No Thumbnail'),
                ),
              ),
              Constants.height16,
            ],
          ),
          RoundedButton('Upload Thumbnail', () => _addThumbnail(model)),
        ],
      ),
    );
  }
}
