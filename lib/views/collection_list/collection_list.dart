import 'package:flutter/material.dart';
import 'package:my_collections/components/image_card.dart';
import 'package:my_collections/components/loading.dart';
import 'package:my_collections/components/autocomplete_search_bar.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/constants.dart';
import 'package:my_collections/components/sort_actions.dart';
import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/mc_db.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:my_collections/models/sql_constants.dart';
import 'package:my_collections/views/add_edit_collection/add_edit_collection.dart';
import 'package:my_collections/components/wide_card_label.dart';
import 'package:my_collections/views/entry_list/entry_list.dart';
import 'package:my_collections/views/settings/settings.dart';

const sortOptions = [
  nameColumn,
  createdAtColumn,
  collectionSizeColumn,
  wantlistSizeColumn,
];

const sortOptionLabels = [
  'Name',
  'Added Date',
  'Collection Size',
  'Wantlist Size',
];

class CollectionList extends StatefulWidget {
  const CollectionList({super.key});

  @override
  State<CollectionList> createState() => _CollectionListState();
}

class _CollectionListState extends State<CollectionList> {
  List<Collection> _collections = [];
  bool _collectionsLoaded = false;

  String searchQuery = '';
  String sortColumn = nameColumn;
  bool sortAsc = true;

  Future<List<Collection>> _loadCollections() async {
    if (!_collectionsLoaded) {
      _collections = await MCDB.collections();
      _collectionsLoaded = true;
    }
    return _collections;
  }

  Future<void> _initViewCollectionRoute(
    Collection collection,
    BuildContext context,
  ) async {
    // await model.initViewCollectionRoute(collection);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryList(collection),
        ),
      );
    }
  }

  void _addCollectionRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditCollection()),
    );
  }

  void _settingsRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Settings()),
    );
  }

  List<Collection> _sortAndFilterCollections(List<Collection> collections) {
    collections.sort(
      (a, b) => _collectionComparator(a, b, sortColumn, sortAsc),
    );
    return collections
        .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  int _collectionComparator(
    Collection c1,
    Collection c2,
    String sortBy,
    bool asc,
  ) {
    var sortResult = switch (sortBy) {
      valueColumn => c1.value.compareTo(c2.value),
      collectionSizeColumn => c1.collectionSize.compareTo(c2.collectionSize),
      wantlistSizeColumn => c1.wantlistSize.compareTo(c2.wantlistSize),
      createdAtColumn => c1.createdAt.compareTo(c2.createdAt),
      nameColumn || _ => c1.name.compareTo(c2.name),
    };
    return (asc ? 1 : -1) * sortResult;
  }

  void _setSortColumn(String column) => setState(() => sortColumn = column);
  void _toggleSortAsc() => setState(() => sortAsc = !sortAsc);
  void _setSearchQuery(String query) => setState(() => searchQuery = query);

  @override
  Widget build(BuildContext context) {
    return LoadAsyncView(
      viewTitle: "My Collections",
      future: _loadCollections(),
      builder: (collections) {
        var filteredCollections = _sortAndFilterCollections(collections ?? []);
        var searchOptions = filteredCollections.map((c) => c.name).toList();
        var collectionCount = filteredCollections.length;
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Collections'),
            actions: [
              IconButton(
                onPressed: () => _settingsRoute(context),
                icon: const Icon(Icons.settings),
              ),
              SortActions(
                sortColumn: sortColumn,
                sortAsc: sortAsc,
                onSortColumnSelected: _setSortColumn,
                onSortAscToggled: _toggleSortAsc,
                sortOptions: sortOptions,
                sortOptionLabels: sortOptionLabels,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: AutocompleteSearchBar(
                hint: 'Search Collections',
                bottom: SimpleText('$collectionCount Collections'),
                searchOptions: searchOptions,
                onChanged: _setSearchQuery,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _addCollectionRoute(context),
          ),
          body: () {
            if (filteredCollections.isNotEmpty) {
              return ListView.separated(
                separatorBuilder: (context, index) => Constants.height16,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filteredCollections.length,
                itemBuilder: (context, index) {
                  var collection = filteredCollections[index];
                  return ImageCard(
                    image: collection.thumbnail,
                    label: WideCardLabel(
                      name: collection.name,
                      collectionSize: collection.collectionSize,
                      wantlistSize: collection.wantlistSize,
                    ),
                    onTap: () => _initViewCollectionRoute(collection, context),
                  );
                },
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: SimpleText(
                  collections?.isNotEmpty ?? false
                      ? 'No results'
                      : 'Add collections using the + button',
                ),
              );
            }
          }(),
        );
      },
    );
  }
}
