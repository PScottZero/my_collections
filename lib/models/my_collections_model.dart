import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/field.dart';
import 'package:my_collections/models/field_config.dart';
import 'package:my_collections/models/folder.dart';
import 'package:my_collections/models/my_collections_db.dart';
import 'package:my_collections/models/my_collections_local_storage.dart';
import 'package:my_collections/models/ordered_image.dart';
import 'package:uuid/uuid.dart';

class MyCollectionsModel extends ChangeNotifier {
  // in-memory data
  List<Collection> _collections = [];
  List<Entry> _entries = [];
  List<Folder> _folders = [];
  bool _collectionsLoaded = false;
  bool _entriesLoaded = false;
  bool _foldersLoaded = false;
  int get collectionCount => _collections.length;
  int get entryCount =>
      _entries.where((e) => e.inWantlist == (wantlist ? 1 : 0)).length;

  // current data
  Collection currCollection = Collection.create();
  List<FieldConfig> currFieldConfigs = [];
  Folder currFolder = Folder.create(-1);
  Entry currEntry = Entry.create(-1);
  Map<int, Field> currFields = {};
  List<OrderedImage> currImages = [];
  Map<String, Uint8List> currImageData = {};
  bool wantlist = false;

  // edit data
  Collection editCollection = Collection.create();
  List<FieldConfig> editFieldConfigs = [];
  List<FieldConfig> removedFieldConfigs = [];
  Map<String, Uint8List> editImageData = {};
  Entry editEntry = Entry.create(-1);
  Map<int, Field> editFields = {};
  List<OrderedImage> editImages = [];
  List<OrderedImage> removedImages = [];
  Folder editFolder = Folder.create(-1);

  // search and sort data
  String collectionSearchQuery = '';
  String entrySearchQuery = '';
  String collectionsSortColumn = nameColumn;
  bool collectionsSortAsc = true;
  String entriesSortColumn = nameColumn;
  bool entriesSortAsc = true;

  // ---------------------------------------------------------------------------
  // Load Current + Edit Data
  // ---------------------------------------------------------------------------

  Future<void> _loadCurrCollection(Collection collection) async {
    currCollection = collection;
    currFieldConfigs = await MyCollectionsDB.fieldConfigs(collection.id);
  }

  Future<void> _loadEditCollection() async {
    editCollection = currCollection.copy();
    editFieldConfigs = await MyCollectionsDB.fieldConfigs(editCollection.id);
  }

  Future<void> _loadCurrEntry(Entry entry) async {
    currEntry = entry;
    currFields = await MyCollectionsDB.fieldsByEntryId(entry.id);
    currImages = await MyCollectionsDB.orderedImagesByEntryId(entry.id);
    currImageData = await MyCollectionsLocalStorage.loadImages(currImages);
  }

  Future<void> _loadEditEntry() async {
    editEntry = currEntry.copy();
    editFields = await MyCollectionsDB.fieldsByEntryId(editEntry.id);
    editImages = await MyCollectionsDB.orderedImagesByEntryId(editEntry.id);
    editImageData = await MyCollectionsLocalStorage.loadImages(editImages);
  }

  Future<void> _loadCurrFolder(Folder folder) async {
    currFolder = folder;
  }

  void _loadEditFolder() async {
    editFolder = currFolder.copy();
  }

  // ---------------------------------------------------------------------------
  // Get Collections, Entries, Field Configs, and Fields
  // ---------------------------------------------------------------------------

  Future<List<Collection>> collections() async {
    if (!_collectionsLoaded) {
      _collections = await MyCollectionsDB.collections();
      setCollectionsSortColumn(nameColumn);
      _collectionsLoaded = true;
    }
    return _collections;
  }

  Future<List<Entry>> entries() async {
    if (!_entriesLoaded) {
      _entries = await MyCollectionsDB.entries(currCollection.id);
      setEntriesSortColumn(createdAtColumn);
      _entriesLoaded = true;
    }
    var entriesFiltered = _entries
        .where((entry) => entry.inWantlist == (wantlist ? 1 : 0))
        .toList();
    return entriesFiltered;
  }

  Future<List<Folder>> folders() async {
    if (!_foldersLoaded) {
      _folders = await MyCollectionsDB.folders(currCollection.id);
      _foldersLoaded = true;
    }
    return _folders;
  }

  // ---------------------------------------------------------------------------
  // Add Collection / Entry
  // ---------------------------------------------------------------------------

  Future<void> addCollection() async {
    await MyCollectionsDB.addCollection(editCollection, editFieldConfigs);
    _collectionsLoaded = false;
    notifyListeners();
  }

  Future<void> addEntry() async {
    editEntry.inWantlist = wantlist ? 1 : 0;
    await createEntryThumbnail();
    await MyCollectionsDB.addEntry(
      currCollection,
      editEntry,
      editFields,
      editImages,
      wantlist,
    );
    await MyCollectionsLocalStorage.saveImages(editImages, editImageData);
    _entriesLoaded = false;
    notifyListeners();
  }

  Future<void> addFolder() async {
    await MyCollectionsDB.addFolder(editFolder);
    _foldersLoaded = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Update Collection / Entry
  // ---------------------------------------------------------------------------

  Future<void> updateCollection() async {
    await MyCollectionsDB.updateCollection(
      editCollection,
      fieldConfigs: editFieldConfigs,
      removedFieldConfigs: removedFieldConfigs,
    );
    await _loadCurrCollection(editCollection);
    _collectionsLoaded = false;
    notifyListeners();
  }

  Future<void> updateEntry() async {
    await createEntryThumbnail();
    await MyCollectionsDB.updateEntry(
      editEntry,
      fields: editFields,
      images: editImages,
      removedImages: removedImages,
      collection: currCollection,
      prevWantlist: currEntry.inWantlist,
    );
    await MyCollectionsLocalStorage.saveImages(editImages, editImageData);
    await MyCollectionsLocalStorage.deleteImages(removedImages);
    await _loadCurrEntry(editEntry);
    _entriesLoaded = false;
    notifyListeners();
  }

  Future<void> updateFolder() async {
    await MyCollectionsDB.updateFolder(editFolder);
    _foldersLoaded = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Remove Collection / Entry
  // ---------------------------------------------------------------------------

  Future<void> removeCollection() async {
    var collectionImages =
        await MyCollectionsDB.orderedImagesByCollectionId(editCollection.id);
    await MyCollectionsLocalStorage.deleteImages(collectionImages);
    await MyCollectionsDB.removeCollection(editCollection.id);
    _collectionsLoaded = false;
    notifyListeners();
  }

  Future<void> removeEntry() async {
    await MyCollectionsDB.removeEntry(currCollection, editEntry.id, wantlist);
    await MyCollectionsLocalStorage.deleteImages(editImages);
    await MyCollectionsLocalStorage.deleteImages(removedImages);
    _entriesLoaded = false;
    notifyListeners();
  }

  Future<void> removeFolder() async {
    await MyCollectionsDB.removeFolder(editFolder.id);
    _foldersLoaded = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Collection / Entry Images
  // ---------------------------------------------------------------------------

  void addCollectionThumbnail(Uint8List thumbnail) {
    editCollection.thumbnail = thumbnail;
    notifyListeners();
  }

  void addFolderThumbnail(Uint8List thumbnail) {
    editFolder.thumbnail = thumbnail;
    notifyListeners();
  }

  Future<void> createEntryThumbnail() async {
    var bytes = editImageData[editImages.firstOrNull?.image ?? ''];
    if (bytes != null) {
      var compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 512,
        minHeight: 512,
        quality: 85,
      );
      editEntry.thumbnail = compressedBytes;
    }
  }

  void addEntryImage(Uint8List bytes, String ext) {
    var uuid = const Uuid().v1();
    var image = '$uuid.$ext';
    editImages.add(OrderedImage.create(currCollection.id, editEntry.id, image));
    editImageData[image] = bytes;
    notifyListeners();
  }

  void reorderEntryImages(int oldIdx, int newIdx) {
    if (oldIdx < newIdx) newIdx -= 1;
    var image = editImages.removeAt(oldIdx);
    editImages.insert(newIdx, image);
    notifyListeners();
  }

  void removeEntryImage(OrderedImage image) {
    removedImages.add(image);
    editImages.remove(image);
    editImageData.remove(image.image);
    notifyListeners();
  }

  Future<void> toggleWantlist(bool switchToWantlist) async {
    wantlist = switchToWantlist;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Collection / Entry Value
  // ---------------------------------------------------------------------------

  String collectionValue() {
    var total = _entries
        .where((entry) => entry.inWantlist == (wantlist ? 1 : 0))
        .map((entry) => _parseValue(entry.value))
        .fold(0.0, (previousValue, value) => previousValue += value);
    return _valueStr(total);
  }

  String entryValue() => _valueStr(_parseValue(currEntry.value));

  // ---------------------------------------------------------------------------
  // Collection / Entry Search
  // ---------------------------------------------------------------------------

  Future<List<Collection>> filteredCollections() async {
    return (await collections())
        .where((c) =>
            c.name.toLowerCase().contains(collectionSearchQuery.toLowerCase()))
        .toList();
  }

  Future<List<Entry>> filteredEntries() async {
    return (await entries())
        .where((e) =>
            e.name.toLowerCase().contains(entrySearchQuery.toLowerCase()))
        .toList();
  }

  List<String> collectionSearchOptions() {
    var collectionNames = _collections.map((c) => c.name).toList();
    collectionNames.sort();
    return collectionNames;
  }

  List<String> entrySearchOptions() {
    var entryNames = _entries.map((e) => e.name).toList();
    entryNames.sort();
    return entryNames;
  }

  List<String> sortFields() {
    List<String> fieldNames = ['Name'];
    for (var fieldConfig in currFieldConfigs) {
      fieldNames.add(fieldConfig.name);
    }
    fieldNames.add('Value');
    return fieldNames;
  }

  // ---------------------------------------------------------------------------
  // Route Initialization
  // ---------------------------------------------------------------------------

  Future<void> viewCollectionInit(Collection collection) async {
    await _loadCurrCollection(collection);
    _entriesLoaded = false;
    _foldersLoaded = false;
    wantlist = false;
  }

  Future<void> viewEntryInit(Entry entry) async {
    await _loadCurrEntry(entry);
  }

  void addCollectionInit() {
    editCollection = Collection.create();
    editFieldConfigs = [];
    removedFieldConfigs = [];
  }

  void addEntryInit() {
    editEntry = Entry.create(currCollection.id);
    editFields = {};
    editImages = [];
    editImageData = {};
    removedImages = [];
    for (var fieldConfig in currFieldConfigs) {
      var field = Field.create(currCollection.id, fieldConfig.id);
      editFields[fieldConfig.id] = field;
    }
  }

  void addFolderInit() {
    editFolder = Folder.create(currCollection.id);
  }

  Future<void> editCollectionInit() async {
    await _loadEditCollection();
    removedFieldConfigs = [];
  }

  Future<void> editEntryInit() async {
    await _loadEditEntry();
    removedImages = [];
  }

  void editFolderInit() {
    _loadEditFolder();
  }

  // ---------------------------------------------------------------------------
  // Search + Sorting
  // ---------------------------------------------------------------------------

  void collectionSearch(String query) {
    collectionSearchQuery = query;
    notifyListeners();
  }

  void entrySearch(String query) {
    entrySearchQuery = query;
    notifyListeners();
  }

  void sortCollections() {
    int Function(Collection, Collection)? sortFunc;

    switch (collectionsSortColumn) {
      case nameColumn:
        sortFunc = (c1, c2) => c1.name.compareTo(c2.name);
        break;
      case valueColumn:
        sortFunc = (c1, c2) {
          return _parseValue(c1.value).compareTo(_parseValue(c2.value));
        };
        break;
      case collectionSizeColumn:
        sortFunc = (c1, c2) => c1.collectionSize.compareTo(c2.collectionSize);
        break;
      case wantlistSizeColumn:
        sortFunc = (c1, c2) => c1.wantlistSize.compareTo(c2.wantlistSize);
        break;
      case createdAtColumn:
        sortFunc = (c1, c2) => c1.createdAt.compareTo(c2.createdAt);
        break;
    }
    _collections.sort(sortFunc);
    if (!collectionsSortAsc) {
      _collections = _collections.reversed.toList();
    }
  }

  void sortEntries() {
    int Function(Entry, Entry)? sortFunc;
    switch (entriesSortColumn) {
      case nameColumn:
        sortFunc = (e1, e2) => e1.name.compareTo(e2.name);
        break;
      case valueColumn:
        sortFunc = (e1, e2) {
          return _parseValue(e1.value).compareTo(_parseValue(e2.value));
        };
        break;
      case createdAtColumn:
        sortFunc = (e1, e2) => e1.createdAt.compareTo(e2.createdAt);
        break;
    }
    _entries.sort(sortFunc);
    if (!entriesSortAsc) {
      _entries = _entries.reversed.toList();
    }
  }

  void setCollectionsSortColumn(String column) {
    collectionsSortColumn = column;
    collectionsSortAsc = column == nameColumn;
    sortCollections();
    notifyListeners();
  }

  void setEntriesSortColumn(String column) {
    entriesSortColumn = column;
    entriesSortAsc = column == nameColumn;
    sortEntries();
    notifyListeners();
  }

  void toggleCollectionsSortAsc() {
    collectionsSortAsc = !collectionsSortAsc;
    _collections = _collections.reversed.toList();
    notifyListeners();
  }

  void toggleEntriesSortAsc() {
    entriesSortAsc = !entriesSortAsc;
    _entries = _entries.reversed.toList();
    notifyListeners();
  }

  double _parseValue(String value) {
    return double.tryParse(value.replaceAll('\$', '').trim()) ?? 0;
  }

  String _valueStr(double value) {
    var valueSplit = value.toStringAsFixed(2).split('.');
    var wholePart = valueSplit.first;
    var decimalPart = valueSplit.last;
    var wholePartFormatted = '';
    int count = 0;
    for (int i = wholePart.length - 1; i >= 0; i--) {
      if (count == 3) {
        wholePartFormatted = ',$wholePartFormatted';
        count = 0;
      }
      count++;
      wholePartFormatted = wholePart[i] + wholePartFormatted;
    }
    return '\$$wholePartFormatted.$decimalPart';
  }

  // ---------------------------------------------------------------------------
  // Backup + Restore
  // ---------------------------------------------------------------------------

  Future<String> backup() async {
    return await MyCollectionsLocalStorage.backup();
  }

  Future<String> restore() async {
    final result = await MyCollectionsLocalStorage.restore();
    MyCollectionsDB.init();
    _collectionsLoaded = false;
    notifyListeners();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  Future<String> refreshCounts() async {
    var collections = await MyCollectionsDB.collections();
    for (var collection in collections) {
      var entries = await MyCollectionsDB.entries(collection.id);
      collection.collectionSize =
          entries.where((c) => c.inWantlist == 0).length;
      collection.wantlistSize = entries.where((c) => c.inWantlist == 1).length;
      await MyCollectionsDB.updateCollection(collection);
    }
    _collectionsLoaded = false;
    notifyListeners();
    return 'Refreshed counts';
  }

  Future<String> refreshThumbnails() async {
    var entries = await MyCollectionsDB.entries_();
    for (var entry in entries) {
      editEntry = entry;
      editImages = await MyCollectionsDB.orderedImagesByEntryId(editEntry.id);
      if (editImages.isNotEmpty) {
        var firstImage = editImages.first.image;
        editImageData.clear();
        editImageData[firstImage] =
            await MyCollectionsLocalStorage.loadImage(firstImage);
        await createEntryThumbnail();
        await MyCollectionsDB.updateEntry(editEntry);
      }
    }
    return 'Refreshed thumbnails';
  }
}
