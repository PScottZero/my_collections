import 'package:flutter/material.dart';
import 'package:my_collections/components/image_card.dart';
import 'package:my_collections/components/loading.dart';
import 'package:my_collections/components/autocomplete_search_bar.dart';
import 'package:my_collections/components/simple_text.dart';
import 'package:my_collections/components/sort_actions.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/mc_model.dart';
import 'package:my_collections/views/add_edit_collection/add_edit_collection.dart';
import 'package:my_collections/views/add_edit_entry/add_edit_entry.dart';
import 'package:my_collections/views/add_edit_folder/add_edit_folder.dart';
import 'package:my_collections/views/entry_details/entry_details.dart';
import 'package:my_collections/views/entry_list/components/folders_list.dart';
import 'package:provider/provider.dart';

class EntryList extends StatefulWidget {
  const EntryList({super.key});

  @override
  State<EntryList> createState() => _EntryListState();
}

class _EntryListState extends State<EntryList> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<MCModel>(
      builder: (context, model, child) {
        var entries = model.filteredEntries;
        var folders = model.filteredFolders;
        var collectionValue = Entry.valueStr(entries
            .map((e) => e.floatValue)
            .fold(0.0, (prevValue, value) => prevValue += value));
        return Scaffold(
          appBar: AppBar(
            title: Text(model.currCollection.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCollectionRoute(context, model),
              ),
              SortActions(
                sortColumn: model.entrySortColumn,
                sortAsc: model.entrySortAsc,
                sortOptions: model.entrySortFields(),
                sortOptionLabels: model.entrySortFields(),
                onSortColumnSelected: (column) =>
                    model.setEntriesSortColumn(column),
                onSortAscToggled: () => model.toggleEntriesSortDir(),
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
                        SimpleText('${entries.length} Entries'),
                        const SizedBox(width: 16),
                        SimpleText(collectionValue, color: Colors.green),
                      ],
                    );
                  } else {
                    return SimpleText('${folders.length} Folders');
                  }
                }(),
                searchOptions: entries
                    .map((e) => e.name)
                    .where((name) => name.isNotEmpty)
                    .toList(),
                onChanged: (query) => model.entrySearch(query),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _selectedIndex == 2
                ? _addFolderRoute(context, model)
                : _addEntryRoute(context, model),
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
              NavigationDestination(
                label: 'Folders',
                icon: Icon(Icons.folder_outlined),
              ),
            ],
            onDestinationSelected: (value) async {
              await model.toggleWantlist(value == 1);
              setState(() => _selectedIndex = value);
            },
          ),
          body: () {
            if (_selectedIndex < 2) {
              return Loading(
                future: model.loadEntries(),
                content: () {
                  if (entries.isNotEmpty) {
                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: () {
                        var entriesMap = entries.map(
                          (entry) => ImageCard(
                            image: entry.thumbnail,
                            label: SimpleText(entry.name, bold: true),
                            onTap: () => _viewEntryRoute(entry, context, model),
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
                        '${model.wantlist ? 'wantlist' : 'collection'} '
                        'using the + button',
                      ),
                    );
                  }
                }(),
              );
            } else {
              return FoldersList(folders: folders);
            }
          }(),
        );
      },
    );
  }
}
