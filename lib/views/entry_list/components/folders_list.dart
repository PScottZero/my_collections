import 'package:flutter/material.dart';
import 'package:my_collections/components/wide_card_label.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/image_card.dart';
import 'package:my_collections/components/loading.dart';
import 'package:my_collections/components/my_text.dart';
import 'package:my_collections/models/my_collections_model.dart';
import 'package:provider/provider.dart';

class FoldersList extends StatelessWidget {
  const FoldersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCollectionsModel>(
      builder: (context, model, child) => Loading(
        future: model.folders(),
        futureWidget: (folders) => IfElse(
          condition: folders.isNotEmpty,
          ifWidget: () => ListView.separated(
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
          ),
          elseWidget: () => const MyText(
            'Add folders using the + button',
            center: true,
          ),
        ),
      ),
    );
  }
}
