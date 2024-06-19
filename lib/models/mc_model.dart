import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:my_collections/models/mc_cache.dart';
import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/field.dart';
import 'package:my_collections/models/field_config.dart';
import 'package:my_collections/models/folder.dart';
import 'package:my_collections/models/mc_db.dart';
import 'package:my_collections/models/mc_local_storage.dart';
import 'package:my_collections/models/ordered_image.dart';
import 'package:my_collections/models/sql_constants.dart';
import 'package:uuid/uuid.dart';

class MCModel extends ChangeNotifier {
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

  // search + sort data
  String collectionSearchQuery = '';
  String entrySearchQuery = '';
  String folderSearchQuery = '';
  String collectionSortColumn = nameColumn;
  String entrySortColumn = nameColumn;
  String folderSortColumn = nameColumn;
  bool collectionSortAsc = true;
  bool entrySortAsc = true;
  bool folderSortAsc = true;

  List<Collection> get filteredCollections => MCCache.collections
      .where((c) =>
          c.name.toLowerCase().contains(collectionSearchQuery.toLowerCase()))
      .toList();
  List<Entry> get filteredEntries => MCCache.entries
      .where(
          (e) => e.name.toLowerCase().contains(entrySearchQuery.toLowerCase()))
      .toList();
  List<Folder> get filteredFolders => MCCache.folders
      .where(
          (f) => f.name.toLowerCase().contains(folderSearchQuery.toLowerCase()))
      .toList();

  // ---------------------------------------------------------------------------
  // Get Collections, Entries, and Folders
  // ---------------------------------------------------------------------------

  Future<bool> loadCollections() async {
    if (!MCCache.collectionsLoaded) {
      await MCCache.loadCollections();
    }
    return true;
  }

  Future<bool> loadEntries() async {
    if (!MCCache.entriesLoaded) {
      await MCCache.loadEntries(currCollection.id, wantlist);
    }
    return true;
  }

  Future<bool> loadFolders() async {
    if (!MCCache.foldersLoaded) {
      await MCCache.loadFolders(currCollection.id);
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Load Current + Edit Data
  // ---------------------------------------------------------------------------

  Future<void> _loadCurrCollection(Collection collection) async {
    currCollection = collection;
    currFieldConfigs = await MCDB.fieldConfigsByCollectionId(collection.id);
  }

  Future<void> _loadEditCollection() async {
    editCollection = currCollection.copy();
    editFieldConfigs = await MCDB.fieldConfigsByCollectionId(editCollection.id);
  }

  Future<void> _loadCurrEntry(Entry entry) async {
    currEntry = entry;
    currFields = await MCDB.fieldsByEntryId(entry.id);
    currImages = await MCDB.orderedImagesByEntryId(entry.id);
    currImageData = await MCLocalStorage.loadImages(currImages);
  }

  Future<void> _loadEditEntry() async {
    editEntry = currEntry.copy();
    editFields = await MCDB.fieldsByEntryId(editEntry.id);
    editImages = await MCDB.orderedImagesByEntryId(editEntry.id);
    editImageData = await MCLocalStorage.loadImages(editImages);
  }

  void _loadEditFolder() async {
    editFolder = currFolder.copy();
  }

  // ---------------------------------------------------------------------------
  // Add Collection / Entry
  // ---------------------------------------------------------------------------

  Future<void> addCollection() async {
    await MCDB.addCollection(editCollection, editFieldConfigs);
    MCCache.resetCollections();
    notifyListeners();
  }

  Future<void> addEntry() async {
    editEntry.inWantlist = wantlist ? 1 : 0;
    await createEntryThumbnail();
    await MCDB.addEntry(
      currCollection,
      editEntry,
      editFields,
      editImages,
      wantlist,
    );
    await MCLocalStorage.saveImages(editImages, editImageData);
    MCCache.resetEntries();
    notifyListeners();
  }

  Future<void> addFolder() async {
    await MCDB.addFolder(editFolder);
    MCCache.resetFolders();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Update Collection / Entry
  // ---------------------------------------------------------------------------

  Future<void> updateCollection() async {
    await MCDB.updateCollection(
      editCollection,
      fieldConfigs: editFieldConfigs,
      removedFieldConfigs: removedFieldConfigs,
    );
    await _loadCurrCollection(editCollection);
    MCCache.resetCollections();
    notifyListeners();
  }

  Future<void> updateEntry() async {
    await createEntryThumbnail();
    await MCDB.updateEntry(
      editEntry,
      fields: editFields,
      images: editImages,
      removedImages: removedImages,
      collection: currCollection,
      prevWantlist: currEntry.inWantlist,
    );
    await MCLocalStorage.saveImages(editImages, editImageData);
    await MCLocalStorage.deleteImages(removedImages);
    await _loadCurrEntry(editEntry);
    MCCache.resetEntries();
    notifyListeners();
  }

  Future<void> updateFolder() async {
    await MCDB.updateFolder(editFolder);
    MCCache.resetFolders();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Remove Collection / Entry
  // ---------------------------------------------------------------------------

  Future<void> removeCollection() async {
    var images = await MCDB.orderedImagesByCollectionId(editCollection.id);
    await MCLocalStorage.deleteImages(images);
    await MCDB.removeCollection(editCollection.id);
    MCCache.resetCollections();
    notifyListeners();
  }

  Future<void> removeEntry() async {
    await MCDB.removeEntry(editEntry.id, currCollection, wantlist);
    await MCLocalStorage.deleteImages(editImages);
    await MCLocalStorage.deleteImages(removedImages);
    MCCache.resetEntries();
    notifyListeners();
  }

  Future<void> removeFolder() async {
    await MCDB.removeFolder(editFolder.id);
    MCCache.resetFolders();
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
      editEntry.thumbnail = await compressImage(bytes);
    }
  }

  static Future<Uint8List> compressImage(Uint8List bytes) async {
    return await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 512,
      minHeight: 512,
      quality: 85,
    );
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
  // Collection / Entry Search
  // ---------------------------------------------------------------------------

  List<String> entrySortFields() {
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

  Future<void> initViewCollectionRoute(Collection collection) async {
    await _loadCurrCollection(collection);
    await MCCache.loadEntries(collection.id, wantlist);
    wantlist = false;
    entrySortColumn = nameColumn;
    entrySortAsc = true;
  }

  Future<void> initViewEntryRoute(Entry entry) async {
    await _loadCurrEntry(entry);
  }

  void initAddCollectionRoute() {
    editCollection = Collection.create();
    editFieldConfigs = [];
    removedFieldConfigs = [];
  }

  void initAddEntryRoute() {
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

  void initAddFolderRoute() {
    editFolder = Folder.create(currCollection.id);
  }

  Future<void> initEditCollectionRoute() async {
    await _loadEditCollection();
    removedFieldConfigs = [];
  }

  Future<void> initEditEntryRoute() async {
    await _loadEditEntry();
    removedImages = [];
  }

  void initEditFolderRoute() {
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

  void setCollectionsSortColumn(String column) {
    collectionSortColumn = column;
    collectionSortAsc = column == nameColumn;
    MCCache.sortCollections(collectionSortColumn, collectionSortAsc);
    notifyListeners();
  }

  void setEntriesSortColumn(String column) {
    entrySortColumn = column;
    entrySortAsc = column == nameColumn;
    MCCache.sortEntries(entrySortColumn, entrySortAsc);
    notifyListeners();
  }

  void toggleCollectionsSortDir() {
    collectionSortAsc = !collectionSortAsc;
    MCCache.reverseCollections();
    notifyListeners();
  }

  void toggleEntriesSortDir() {
    entrySortAsc = !entrySortAsc;
    MCCache.reverseEntries();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Backup + Restore
  // ---------------------------------------------------------------------------

  Future<String> backup() async {
    return await MCLocalStorage.backup();
  }

  Future<String> restore() async {
    final result = await MCLocalStorage.restore();
    MCDB.init();
    MCCache.resetCollections();
    MCCache.resetEntries();
    MCCache.resetFolders();
    notifyListeners();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  Future<String> refreshCounts() async {
    var collections = await MCDB.collections();
    for (var collection in collections) {
      var entries = await MCDB.entriesByCollectionId(collection.id);
      collection.collectionSize =
          entries.where((c) => c.inWantlist == 0).length;
      collection.wantlistSize = entries.where((c) => c.inWantlist == 1).length;
      await MCDB.updateCollection(collection);
    }
    MCCache.resetCollections();
    notifyListeners();
    return 'Refreshed counts';
  }

  Future<String> refreshThumbnails() async {
    for (var entry in (await MCDB.entries())) {
      var entryImages = await MCDB.orderedImagesByEntryId(entry.id);
      if (entryImages.isNotEmpty) {
        var firstImage = entryImages.first.image;
        var imageBytes = await MCLocalStorage.loadImage(firstImage);
        if (imageBytes.isNotEmpty) {
          entry.thumbnail = await compressImage(imageBytes);
          await MCDB.updateEntry(entry);
        }
      }
    }
    return 'Refreshed thumbnails';
  }
}
