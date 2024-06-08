import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/field.dart';
import 'package:my_collections/models/field_config.dart';
import 'package:my_collections/models/folder.dart';
import 'package:my_collections/models/ordered_image.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

typedef DBObject = Map<String, dynamic>;

// -----------------------------------------------------------------------------
// Table Names
// -----------------------------------------------------------------------------

const collectionsTable = 'collections';
const entriesTable = 'entries';
const fieldConfigsTable = 'fieldConfigs';
const fieldsTable = 'fields';
const orderedImagesTable = 'orderedImages';
const foldersTable = 'folders';
const folderEntriesTable = 'folderEntries';

// -----------------------------------------------------------------------------
// Column Names
// -----------------------------------------------------------------------------

const idColumn = 'id';
const nameColumn = 'name';
const thumbnailColumn = 'thumbnail';
const createdAtColumn = 'createdAt';
const inWantlistColumn = 'inWantlist';
const indexColumn = 'idx';
const valueColumn = 'value';
const imageColumn = 'image';
const collectionIdColumn = 'collectionId';
const entryIdColumn = 'entryId';
const folderIdColumn = 'folderId';
const fieldConfigIdColumn = 'fieldConfigId';
const collectionSizeColumn = 'collectionSize';
const wantlistSizeColumn = 'wantlistSize';

// -----------------------------------------------------------------------------
// SQL Create Table Queries
// -----------------------------------------------------------------------------

const createCollectionsTableSQL = '''
CREATE TABLE $collectionsTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $nameColumn TEXT,
  $valueColumn TEXT,
  $thumbnailColumn BLOB,
  $collectionSizeColumn INTEGER,
  $wantlistSizeColumn INTEGER,
  $createdAtColumn TEXT
)
''';
const createEntriesTableSQL = '''
CREATE TABLE $entriesTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $collectionIdColumn INTEGER,
  $nameColumn TEXT,
  $valueColumn TEXT,
  $thumbnailColumn BLOB,
  $inWantlistColumn INTEGER,
  $createdAtColumn TEXT,
  FOREIGN KEY ($collectionIdColumn) REFERENCES $collectionsTable ($idColumn)
)
''';
const createFieldConfigsTableSQL = '''
CREATE TABLE $fieldConfigsTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $collectionIdColumn INTEGER,
  $nameColumn TEXT,
  $indexColumn INTEGER,
  FOREIGN KEY ($collectionIdColumn) REFERENCES $collectionsTable ($idColumn)
)
''';
const createFieldsTableSQL = '''
CREATE TABLE $fieldsTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $collectionIdColumn INTEGER,
  $entryIdColumn INTEGER,
  $fieldConfigIdColumn INTEGER,
  $valueColumn TEXT,
  FOREIGN KEY ($collectionIdColumn) REFERENCES $collectionsTable ($idColumn),
  FOREIGN KEY ($entryIdColumn) REFERENCES $entriesTable ($idColumn),
  FOREIGN KEY ($fieldConfigIdColumn) REFERENCES $fieldConfigsTable ($idColumn)
)
''';
const createOrderedImagesTableSQL = '''
CREATE TABLE $orderedImagesTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $collectionIdColumn INTEGER,
  $entryIdColumn INTEGER,
  $imageColumn TEXT,
  $indexColumn INTEGER,
  FOREIGN KEY ($collectionIdColumn) REFERENCES $collectionsTable ($idColumn),
  FOREIGN KEY ($entryIdColumn) REFERENCES $entriesTable ($idColumn)
)
''';
const createFoldersTableSQL = '''
CREATE TABLE $foldersTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $collectionIdColumn INTEGER,
  $nameColumn TEXT,
  $valueColumn TEXT,
  $thumbnailColumn BLOB,
  $collectionSizeColumn INTEGER,
  $wantlistSizeColumn INTEGER,
  $createdAtColumn TEXT,
  FOREIGN KEY ($collectionIdColumn) REFERENCES $collectionsTable ($idColumn)
)
''';
const createFolderEntriesTableSQL = '''
CREATE TABLE $folderEntriesTable(
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $folderIdColumn INTEGER,
  $entryIdColumn INTEGER,
  FOREIGN KEY ($folderIdColumn) REFERENCES $foldersTable ($idColumn),
  FOREIGN KEY ($entryIdColumn) REFERENCES $entriesTable ($idColumn)
)
''';

// -----------------------------------------------------------------------------
// My Collections DB Class
// -----------------------------------------------------------------------------

class MCDB {
  static Database? db;
  static String dbPath = '';
  static const String dbName = 'myCollections.db';

  static Future<void> init() async {
    dbPath = join(await getDatabasesPath(), dbName);
    db = await openDatabase(
      dbPath,
      onCreate: (dbInit, version) async {
        await dbInit.execute(createCollectionsTableSQL);
        await dbInit.execute(createEntriesTableSQL);
        await dbInit.execute(createFieldConfigsTableSQL);
        await dbInit.execute(createFieldsTableSQL);
        await dbInit.execute(createOrderedImagesTableSQL);
        await dbInit.execute(createFoldersTableSQL);
        await dbInit.execute(createFolderEntriesTableSQL);
      },
      version: 1,
    );
  }

  // ---------------------------------------------------------------------------
  // DB Get Functions
  // ---------------------------------------------------------------------------

  static Future<List<Collection>> collections({String? where}) async =>
      await _dbGet(collectionsTable, (DBObject obj) => Collection.fromMap(obj),
          where: where);

  static Future<List<Entry>> entries({String? where}) async =>
      await _dbGet(entriesTable, (DBObject obj) => Entry.fromMap(obj),
          where: where);

  static Future<List<FieldConfig>> fieldConfigs({String? where}) async =>
      await _dbGet(
          fieldConfigsTable, (DBObject obj) => FieldConfig.fromMap(obj),
          where: where, orderBy: '$indexColumn ASC');

  static Future<Map<int, Field>> fields({String? where}) async =>
      _fieldsToFieldMap(await _dbGet(
          fieldsTable, (DBObject obj) => Field.fromMap(obj),
          where: where));

  static Future<List<OrderedImage>> orderedImages({String? where}) async =>
      await _dbGet(
          orderedImagesTable, (DBObject obj) => OrderedImage.fromMap(obj),
          where: where, orderBy: '$indexColumn ASC');

  static Future<List<Folder>> folders({String? where}) async =>
      await _dbGet(orderedImagesTable, (DBObject obj) => Folder.fromMap(obj),
          where: where, orderBy: '$indexColumn ASC');

  static Future<List<T>> _dbGet<T>(
    String table,
    T Function(DBObject) generator, {
    String? where,
    String? orderBy,
  }) async {
    var results = await db!.query(table, where: where, orderBy: orderBy);
    return List.generate(results.length, (index) => generator(results[index]));
  }

  static Map<int, Field> _fieldsToFieldMap(List<Field> fields) {
    var fieldMap = <int, Field>{};
    for (var field in fields) {
      fieldMap[field.fieldConfigId] = field;
    }
    return fieldMap;
  }

  // ---------------------------------------------------------------------------
  // DB Filtered Get Functions
  // ---------------------------------------------------------------------------

  static Future<List<Entry>> entriesByCollectionId(int id) async =>
      await entries(where: '$collectionIdColumn = $id');

  static Future<List<OrderedImage>> orderedImagesByCollectionId(int id) async =>
      await orderedImages(where: '$collectionIdColumn = $id');

  static Future<List<OrderedImage>> orderedImagesByEntryId(int id) async =>
      await orderedImages(where: '$entryIdColumn = $id');

  static Future<List<FieldConfig>> fieldConfigsByCollectionId(int id) async =>
      await fieldConfigs(where: '$collectionIdColumn = $id');

  static Future<Map<int, Field>> fieldsByEntryId(int id) async =>
      await fields(where: '$entryIdColumn = $id');

  static Future<List<Folder>> foldersByCollectionId(int id) async =>
      await folders(where: '$collectionIdColumn = $id');

  // ---------------------------------------------------------------------------
  // DB Insert Functions
  // ---------------------------------------------------------------------------

  static Future<int> addCollection(
    Collection collection,
    List<FieldConfig> fieldConfigs,
  ) async {
    int id = await db!.insert(collectionsTable, removeId(collection.toMap()));
    for (var i = 0; i < fieldConfigs.length; i++) {
      fieldConfigs[i].collectionId = id;
      fieldConfigs[i].idx = i;
      await addFieldConfig(fieldConfigs[i]);
    }
    return id;
  }

  static Future<int> addEntry(
    Collection collection,
    Entry entry,
    Map<int, Field> fields,
    List<OrderedImage> images,
    bool wantlist,
  ) async {
    int id = await db!.insert(entriesTable, removeId(entry.toMap()));
    for (var field in fields.values) {
      field.entryId = id;
      await addField(field);
    }
    for (var i = 0; i < images.length; i++) {
      images[i].entryId = id;
      images[i].idx = i;
      await addOrderedImage(images[i]);
    }
    collection.incrementSize(wantlist);
    await updateCollection(collection);
    return id;
  }

  static Future<int> addFieldConfig(FieldConfig fieldConfig) async =>
      await db!.insert(fieldConfigsTable, removeId(fieldConfig.toMap()));

  static Future<int> addField(Field field) async =>
      await db!.insert(fieldsTable, removeId(field.toMap()));

  static Future<int> addOrderedImage(OrderedImage image) async =>
      await db!.insert(orderedImagesTable, removeId(image.toMap()));

  static Future<int> addFolder(Folder folder) async =>
      await db!.insert(foldersTable, removeId(folder.toMap()));

  static Map<String, dynamic> removeId(Map<String, dynamic> m) {
    m.remove(idColumn);
    return m;
  }

  // ---------------------------------------------------------------------------
  // DB Update Functions
  // ---------------------------------------------------------------------------

  static Future<void> updateCollection(
    Collection collection, {
    List<FieldConfig>? fieldConfigs,
    List<FieldConfig>? removedFieldConfigs,
  }) async {
    await db!.update(
      collectionsTable,
      collection.toMap(),
      where: '$idColumn = ${collection.id}',
    );

    if (fieldConfigs != null && removedFieldConfigs != null) {
      for (var i = 0; i < fieldConfigs.length; i++) {
        fieldConfigs[i].idx = i;
        await updateFieldConfig(fieldConfigs[i]);
      }

      for (var removedFieldConfig in removedFieldConfigs) {
        await removeFieldConfig(removedFieldConfig.id);
      }
    }
  }

  static Future<void> updateEntry(
    Entry entry, {
    Map<int, Field>? fields,
    List<OrderedImage>? images,
    List<OrderedImage>? removedImages,
    Collection? collection,
    int? prevWantlist,
  }) async {
    await db!.update(
      entriesTable,
      entry.toMap(),
      where: '$idColumn = ${entry.id}',
    );

    if (fields != null) {
      for (var field in fields.values) {
        await db!.update(
          fieldsTable,
          field.toMap(),
          where: '$idColumn = ${field.id}',
        );
      }
    }

    if (images != null && removedImages != null) {
      for (var i = 0; i < images.length; i++) {
        images[i].idx = i;
        await updateOrderedImage(images[i]);
      }

      for (var removedImage in removedImages) {
        await removeOrderedImage(removedImage.id);
      }
    }

    if (collection != null && prevWantlist != entry.inWantlist) {
      collection.toggleSize(entry.inWantlist == 1);
      await updateCollection(collection);
    }
  }

  static Future<void> updateFieldConfig(FieldConfig fieldConfig) async {
    if (await fieldConfigExists(fieldConfig.id)) {
      await db!.update(
        fieldConfigsTable,
        fieldConfig.toMap(),
        where: '$idColumn = ${fieldConfig.id}',
      );
    } else {
      int fieldConfigId = await addFieldConfig(fieldConfig);
      var collectionEntries =
          await entriesByCollectionId(fieldConfig.collectionId);
      for (var entry in collectionEntries) {
        await db!.insert(
          fieldsTable,
          removeId(Field.create(
            fieldConfig.collectionId,
            fieldConfigId,
            entryId: entry.id,
          ).toMap()),
        );
      }
    }
  }

  static Future<void> updateOrderedImage(OrderedImage image) async {
    if (await orderedImageExists(image.id)) {
      await db!.update(
        orderedImagesTable,
        image.toMap(),
        where: '$idColumn = ${image.id}',
      );
    } else {
      await addOrderedImage(image);
    }
  }

  static Future<void> updateFolder(Folder folder) async =>
      await db!.update(foldersTable, folder.toMap());

  // ---------------------------------------------------------------------------
  // DB Delete Functions
  // ---------------------------------------------------------------------------

  static Future<void> removeCollection(int id) async {
    await db!.delete(fieldsTable, where: '$collectionIdColumn = $id');
    await db!.delete(orderedImagesTable, where: '$collectionIdColumn = $id');
    await db!.delete(fieldConfigsTable, where: '$collectionIdColumn = $id');
    await db!.delete(entriesTable, where: '$collectionIdColumn = $id');
    await db!.delete(collectionsTable, where: '$idColumn = $id');
  }

  static Future<void> removeEntry(
    int id,
    Collection collection,
    bool wantlist,
  ) async {
    await db!.delete(fieldsTable, where: '$entryIdColumn = $id');
    await db!.delete(entriesTable, where: '$idColumn = $id');
    collection.decrementSize(wantlist);
    await updateCollection(collection);
  }

  static Future<void> removeFieldConfig(int id) async {
    await db!.delete(fieldsTable, where: '$fieldConfigIdColumn = $id');
    await db!.delete(fieldConfigsTable, where: '$idColumn = $id');
  }

  static Future<void> removeOrderedImage(int id) async =>
      await db!.delete(orderedImagesTable, where: '$idColumn = $id');

  static Future<void> removeFolder(int id) async =>
      await db!.delete(foldersTable, where: '$idColumn = $id');

  // ---------------------------------------------------------------------------
  // DB Count Functions
  // ---------------------------------------------------------------------------

  static Future<bool> fieldConfigExists(int fieldConfigId) async =>
      await exists(fieldConfigsTable, where: '$idColumn = $fieldConfigId');

  static Future<bool> orderedImageExists(int orderedImageId) async =>
      await exists(orderedImagesTable, where: '$idColumn = $orderedImageId');

  static Future<bool> exists(String table, {String where = ''}) async {
    String query = 'SELECT COUNT(1) FROM $table';
    if (where.isNotEmpty) query += ' WHERE $where';
    int? count = Sqflite.firstIntValue(await db!.rawQuery(query));
    return (count ?? 0) > 0;
  }
}
