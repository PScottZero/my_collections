import 'package:flutter/material.dart';
import 'package:my_collections/components/wide_card_label.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/components/image_card.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/models/folder.dart';

class FoldersList extends StatelessWidget {
  final List<Folder> folders;

  const FoldersList({required this.folders, super.key});

  @override
  Widget build(BuildContext context) {
    if (folders.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (context, index) => Constants.height16,
        padding: Constants.padding16,
        itemCount: folders.length,
        itemBuilder: (context, index) {
          var folder = folders[index];
          return ImageCard(
            image: folder.thumbnail,
            label: WideCardLabel(
              name: folder.name,
              collectionSize: folder.collectionSize,
              wantlistSize: folder.wantlistSize,
            ),
            onTap: () => null,
          );
        },
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: const SimpleText(
          'Add folders using the + button',
          center: true,
        ),
      );
    }
  }
}
