import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/folder.dart';
import 'package:my_collections/models/mc_db.dart';

class MCCache {
  static List<Collection> _collections = [];
  static List<Entry> _entries = [];
  static List<Entry> _wantlist = [];
  static List<Folder> _folders = [];

  static bool _collectionsLoaded = false;
  static bool _entriesLoaded = false;
  static bool _foldersLoaded = false;

  static void resetCollections() => _collectionsLoaded = false;
  static void resetEntries() => _entriesLoaded = false;
  static void resetFolders() => _foldersLoaded = false;

  static int get collectionCount => _collections.length;
  static int get entryCount => _entries.length;
  static int get wantlistCount => _wantlist.length;
  static int get folderCount => _folders.length;
  static String get collectionValue => Entry.valueStr(_entries
      .map((e) => e.floatValue)
      .fold(0.0, (prevValue, value) => prevValue += value));
  static String get wantlistValue => Entry.valueStr(_wantlist
      .map((e) => e.floatValue)
      .fold(0.0, (prevValue, value) => prevValue += value));

  // ---------------------------------------------------------------------------
  // Get Cache
  // ---------------------------------------------------------------------------

  static Future<List<Collection>> collections() async {
    if (!_collectionsLoaded) {
      _collections = await MCDB.collections();
      sortCollections(nameColumn, true);
      _collectionsLoaded = true;
    }
    return _collections;
  }

  static Future<List<Entry>> entries(
    int collectionId,
    bool wantlist,
  ) async {
    if (!_entriesLoaded) {
      var entries = await MCDB.entries(collectionId);
      _entries = entries.where((e) => e.inWantlist == 0).toList();
      _wantlist = entries.where((e) => e.inWantlist == 1).toList();
      sortEntries(nameColumn, true);
      _entriesLoaded = true;
    }
    return wantlist ? _wantlist : _entries;
  }

  static Future<List<Folder>> folders(int collectionId) async {
    if (!_foldersLoaded) {
      _folders = await MCDB.folders(collectionId);
      _foldersLoaded = true;
    }
    return _folders;
  }

  // ---------------------------------------------------------------------------
  // Sort Cache
  // ---------------------------------------------------------------------------

  static void sortCollections(String sortBy, bool asc) {
    _collections.sort((c1, c2) => _collectionComparator(c1, c2, sortBy, asc));
  }

  static void sortEntries(String sortBy, bool asc) {
    _entries.sort((e1, e2) => _entryComparator(e1, e2, sortBy, asc));
    _wantlist.sort((e1, e2) => _entryComparator(e1, e2, sortBy, asc));
  }

  static void reverseCollections() {
    _collections = _collections.reversed.toList();
  }

  static void reverseEntries() {
    _entries = _entries.reversed.toList();
    _wantlist = _wantlist.reversed.toList();
  }

  static void reverseFolders() {
    _folders = _folders.reversed.toList();
  }

  static int _collectionComparator(
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

  static int _entryComparator(
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
}
