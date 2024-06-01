import 'package:flutter/material.dart';
import 'package:my_collections/components/if_else.dart';
import 'package:my_collections/components/image_card.dart';
import 'package:my_collections/components/loading.dart';
import 'package:my_collections/components/my_search_bar.dart';
import 'package:my_collections/components/my_text.dart';
import 'package:my_collections/components/constants.dart';
import 'package:my_collections/components/sort_actions.dart';
import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/my_collections_db.dart';
import 'package:my_collections/models/my_collections_model.dart';
import 'package:my_collections/views/add_edit_collection/add_edit_collection.dart';
import 'package:my_collections/components/wide_card_label.dart';
import 'package:my_collections/views/entry_list/entry_list.dart';
import 'package:my_collections/views/settings/settings.dart';
import 'package:provider/provider.dart';

class CollectionList extends StatelessWidget {
  const CollectionList({super.key});

  Future<void> _viewCollectionRoute(
    Collection collection,
    BuildContext context,
    MyCollectionsModel model,
  ) async {
    await model.viewCollectionInit(collection);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EntryList()),
      );
    }
  }

  void _addCollectionRoute(BuildContext context, MyCollectionsModel model) {
    model.addCollectionInit();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditCollection()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCollectionsModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('My Collections'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              },
              icon: const Icon(Icons.settings),
            ),
            SortActions(
              sortColumn: model.collectionsSortColumn,
              sortAsc: model.collectionsSortAsc,
              onSortColumnSelected: (column) =>
                  model.setCollectionsSortColumn(column),
              onSortAscToggled: () => model.toggleCollectionsSortAsc(),
              sortOptions: const [
                nameColumn,
                createdAtColumn,
                collectionSizeColumn,
                wantlistSizeColumn,
              ],
              sortOptionLabels: const [
                'Name',
                'Added Date',
                'Collection Size',
                'Wantlist Size'
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: MySearchBar(
              hint: 'Search Collections',
              bottom: MyText('${model.collectionCount} Collections'),
              onChanged: (query) => model.collectionSearch(query),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _addCollectionRoute(context, model),
        ),
        body: Loading(
          future: model.filteredCollections(),
          futureWidget: (collections) => IfElse(
            condition: collections.isNotEmpty,
            ifWidget: () => ListView.separated(
              separatorBuilder: (context, index) => Constants.height16,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: collections.length,
              itemBuilder: (context, index) {
                var collection = collections[index];
                return ImageCard(
                  image: collection.thumbnail,
                  label: WideCardLabel(
                    name: collection.name,
                    collectionSize: collection.collectionSize,
                    wantlistSize: collection.wantlistSize,
                  ),
                  onTap: () => _viewCollectionRoute(collection, context, model),
                );
              },
            ),
            elseWidget: () => const MyText(
              'Add collections using the + button',
              center: true,
            ),
          ),
        ),
      ),
    );
  }
}
