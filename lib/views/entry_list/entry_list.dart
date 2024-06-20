import 'package:flutter/material.dart';
import 'package:my_collections/components/autocomplete_search_bar.dart';
import 'package:my_collections/components/image_card.dart';
import 'package:my_collections/components/loading.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/components/sort_actions.dart';
import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/mc_db.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:my_collections/models/sql_constants.dart';
import 'package:my_collections/views/add_edit_collection/add_edit_collection.dart';
import 'package:my_collections/views/add_edit_entry/add_edit_entry.dart';
import 'package:my_collections/views/add_edit_folder/add_edit_folder.dart';
import 'package:my_collections/views/entry_details/entry_details.dart';

const sortOptions = [
  nameColumn,
  valueColumn,
  createdAtColumn,
];

const sortOptionLabels = [
  'Name',
  'Value',
  'Added Date',
];

class EntryList extends StatefulWidget {
  final Collection collection;

  const EntryList(this.collection, {super.key});

  @override
  State<EntryList> createState() => _EntryListState();
}

class _EntryListState extends State<EntryList> {
  List<Entry> _entries = [];
  bool _entriesLoaded = false;

  String searchQuery = '';
  String sortColumn = nameColumn;
  bool sortAsc = true;

  int _selectedIndex = 0;

  bool get wantlist => _selectedIndex == 1;

  Future<List<Entry>> _loadEntries() async {
    if (!_entriesLoaded) {
      _entries = await MCDB.entriesByCollectionId(widget.collection.id);
      _entriesLoaded = true;
    }
    return _entries;
  }

  Future<void> _viewEntryRoute(
    Entry entry,
    BuildContext context,
    MCModel model,
  ) async {
    await model.initViewEntryRoute(entry);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EntryDetails()),
      );
    }
  }

  void _addEntryRoute(BuildContext context, MCModel model) {
    model.initAddEntryRoute();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditEntry()),
    );
  }

  void _addFolderRoute(BuildContext context, MCModel model) {
    model.initAddFolderRoute();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditFolder()),
    );
  }

  void _editCollectionRoute(
    BuildContext context,
    MCModel model,
  ) async {
    await model.initEditCollectionRoute();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEditCollection(edit: true),
        ),
      );
    }
  }

  List<Entry> _sortAndFilterEntries(List<Entry> entries) {
    entries.sort((a, b) => _entryComparator(a, b, sortColumn, sortAsc));
    return entries
        .where((e) =>
            e.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
            e.inWantlist == (wantlist ? 1 : 0))
        .toList();
  }

  int _entryComparator(
    Entry e1,
    Entry e2,
    String sortBy,
    bool asc,
  ) {
    var sortResult = switch (sortBy) {
      valueColumn => e1.value.compareTo(e2.value),
      createdAtColumn => e1.createdAt.compareTo(e2.createdAt),
      nameColumn || _ => e1.name.compareTo(e2.name),
    };
    return (asc ? 1 : -1) * sortResult;
  }

  void _setSortColumn(String column) => setState(() => sortColumn = column);
  void _toggleSortAsc() => setState(() => sortAsc = !sortAsc);
  void _setSearchQuery(String query) => setState(() => searchQuery = query);

  @override
  Widget build(BuildContext context) {
    return LoadAsyncView(
      viewTitle: widget.collection.name,
      future: _loadEntries(),
      builder: (entries) {
        var filteredEntries = _sortAndFilterEntries(entries ?? []);
        var searchOptions = filteredEntries.map((e) => e.name).toList();
        var entryCount = filteredEntries.length;
        var collectionValue = Entry.valueStr(filteredEntries
            .map((e) => e.floatValue)
            .fold(0.0, (prevValue, value) => prevValue += value));
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.collection.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
                // onPressed: () => _editCollectionRoute(context, model),
              ),
              SortActions(
                sortColumn: sortColumn,
                sortAsc: sortAsc,
                sortOptions: sortOptionLabels,
                sortOptionLabels: sortOptionLabels,
                onSortColumnSelected: _setSortColumn,
                onSortAscToggled: _toggleSortAsc,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: AutocompleteSearchBar(
                hint: 'Search Entries',
                bottom: () {
                  if (_selectedIndex < 2) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SimpleText('$entryCount Entries'),
                        const SizedBox(width: 16),
                        SimpleText(collectionValue, color: Colors.green),
                      ],
                    );
                  } else {
                    return Container();
                    // return SimpleText('${folders.length} Folders');
                  }
                }(),
                searchOptions: searchOptions,
                onChanged: _setSearchQuery,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {},
            // onPressed: () => _selectedIndex == 2
            //     ? _addFolderRoute(context, model)
            //     : _addEntryRoute(context, model),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            destinations: const [
              NavigationDestination(
                label: 'Collection',
                icon: Icon(Icons.grid_view),
              ),
              NavigationDestination(
                label: 'Wantlist',
                icon: Icon(Icons.favorite_outline),
              ),
              // NavigationDestination(
              //   label: 'Folders',
              //   icon: Icon(Icons.folder_outlined),
              // ),
            ],
            onDestinationSelected: (value) async {
              // await model.toggleWantlist(value == 1);
              setState(() => _selectedIndex = value);
            },
          ),
          body: () {
            if (_selectedIndex < 2) {
              if (filteredEntries.isNotEmpty) {
                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: () {
                    var entriesMap = filteredEntries.map(
                      (entry) => ImageCard(
                        image: entry.thumbnail,
                        label: SimpleText(entry.name, bold: true),
                        onTap: () {},
                        // onTap: () => _viewEntryRoute(entry, context, model),
                      ),
                    );
                    return entriesMap.toList();
                  }(),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: SimpleText(
                    'Add entries to '
                    '${wantlist ? 'wantlist' : 'collection'} '
                    'using the + button',
                  ),
                );
              }
            } else {
              return Container();
              // return FoldersList(folders: folders);
            }
          }(),
        );
      },
    );
  }
}
