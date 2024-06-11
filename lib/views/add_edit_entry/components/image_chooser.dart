import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_collections/components/rounded_button.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:my_collections/views/add_edit_entry/components/deletable_image.dart';
import 'package:provider/provider.dart';

class ImageChooser extends StatelessWidget {
  const ImageChooser({super.key});

  Future<void> _pickImage(MCModel model) async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      var ext = image.name.split('.').lastOrNull;
      model.addEntryImage(await image.readAsBytes(), ext ?? 'jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) => Column(
        children: [
          SizedBox(
            height: Constants.thumbnailHeight,
            child: IfElse(
              condition: model.editImages.isNotEmpty,
              ifWidget: () {
                return ReorderableListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  onReorder: model.reorderEntryImages,
                  children: () {
                    var images = model.editImages.asMap().entries;
                    var tiles = images.map(
                      (entry) => Container(
                        key: Key(entry.key.toString()),
                        child: Row(
                          children: [
                            DeletableImage(
                              image: model.editImageData[entry.value.image]!,
                              onDelete: () =>
                                  model.removeEntryImage(entry.value),
                            ),
                            IfElse(
                              condition:
                                  entry.key < (model.editImages.length - 1),
                              ifWidget: () => Constants.width16,
                            ),
                          ],
                        ),
                      ),
                    );
                    return tiles.toList();
                  }(),
                );
              },
              elseWidget: () => const SimpleText('No Images', center: true),
            ),
          ),
          Constants.height16,
          RoundedButton('Add Image', () => _pickImage(model)),
        ],
      ),
    );
  }
}
