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

  // search and sort data
  String collectionSearchQuery = '';
  String entrySearchQuery = '';
  String collectionsSortColumn = nameColumn;
  bool collectionsSortAsc = true;
  String entriesSortColumn = nameColumn;
  bool entriesSortAsc = true;

  // stats
  int get collectionCount => MCCache.collectionCount;
  int get entryCount => wantlist ? MCCache.wantlistCount : MCCache.entryCount;
  int get folderCount => MCCache.folderCount;
  String get collectionValue =>
      wantlist ? MCCache.wantlistValue : MCCache.collectionValue;

  // ---------------------------------------------------------------------------
  // Get Collections, Entries, and Folders
  // ---------------------------------------------------------------------------

  Future<List<Collection>> collections() async {
    return (await MCCache.collections()).where((c) {
      return c.name.toLowerCase().contains(collectionSearchQuery.toLowerCase());
    }).toList();
  }

  Future<List<Entry>> entries() async {
    return (await MCCache.entries(currCollection.id, wantlist)).where((e) {
      return e.name.toLowerCase().contains(entrySearchQuery.toLowerCase());
    }).toList();
  }

  Future<List<Folder>> folders() async {
    return await MCCache.folders(currCollection.id);
  }

  // ---------------------------------------------------------------------------
  // Load Current + Edit Data
  // ---------------------------------------------------------------------------

  Future<void> _loadCurrCollection(Collection collection) async {
    currCollection = collection;
    currFieldConfigs = await MCDB.fieldConfigs(collection.id);
  }

  Future<void> _loadEditCollection() async {
    editCollection = currCollection.copy();
    editFieldConfigs = await MCDB.fieldConfigs(editCollection.id);
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
    await MCDB.removeEntry(currCollection, editEntry.id, wantlist);
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
    MCCache.resetEntries();
    MCCache.resetFolders();
    wantlist = false;
    entrySearchQuery = '';
    entriesSortColumn = nameColumn;
    entriesSortAsc = true;
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
    collectionsSortColumn = column;
    collectionsSortAsc = column == nameColumn;
    MCCache.sortCollections(collectionsSortColumn, collectionsSortAsc);
    notifyListeners();
  }

  void setEntriesSortColumn(String column) {
    entriesSortColumn = column;
    entriesSortAsc = column == nameColumn;
    MCCache.sortEntries(entriesSortColumn, entriesSortAsc);
    notifyListeners();
  }

  void toggleCollectionsSortDir() {
    collectionsSortAsc = !collectionsSortAsc;
    MCCache.reverseCollections();
    notifyListeners();
  }

  void toggleEntriesSortDir() {
    entriesSortAsc = !entriesSortAsc;
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
      var entries = await MCDB.entries(collection.id);
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
    for (var entry in (await MCDB.allEntries())) {
      var entryImages = await MCDB.orderedImagesByEntryId(entry.id);
      if (entryImages.isNotEmpty) {
        var firstImage = entryImages.first.image;
        var imageBytes = await MCLocalStorage.loadImage(firstImage);
        entry.thumbnail = await compressImage(imageBytes);
        await MCDB.updateEntry(entry);
      }
    }
    return 'Refreshed thumbnails';
  }
}
