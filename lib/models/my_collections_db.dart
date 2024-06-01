import 'package:my_collections/models/collection.dart';
import 'package:my_collections/models/entry.dart';
import 'package:my_collections/models/field.dart';
import 'package:my_collections/models/field_config.dart';
import 'package:my_collections/models/folder.dart';
import 'package:my_collections/models/ordered_image.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

class MyCollectionsDB {
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

  static Future<List<Collection>> collections() async {
    final results = await db!.query(collectionsTable);
    return List.generate(
      results.length,
      (index) => Collection.fromMap(results[index]),
    );
  }

  static Future<List<Entry>> entries_() async {
    var results = await db!.query(entriesTable);
    return List.generate(
      results.length,
      (index) => Entry.fromMap(results[index]),
    );
  }

  static Future<List<Entry>> entries(int collectionId) async {
    var results = await db!.query(
      entriesTable,
      where: '$collectionIdColumn = $collectionId',
    );
    return List.generate(
      results.length,
      (index) => Entry.fromMap(results[index]),
    );
  }

  static Future<List<FieldConfig>> fieldConfigs(int collectionId) async {
    final results = await db!.query(
      fieldConfigsTable,
      where: '$collectionIdColumn = $collectionId',
      orderBy: '$indexColumn ASC',
    );
    return List.generate(
      results.length,
      (idx) => FieldConfig.fromMap(results[idx]),
    );
  }

  static Future<List<Field>> fieldsByCollectionId(int collectionId) async {
    final results = await db!.query(
      fieldsTable,
      where: '$collectionIdColumn = $collectionId',
    );
    return List.generate(
      results.length,
      (index) => Field.fromMap(results[index]),
    );
  }

  static Future<Map<int, Field>> fieldsByEntryId(int entryId) async {
    final results = await db!.query(
      fieldsTable,
      where: '$entryIdColumn = $entryId',
    );
    var fieldMap = <int, Field>{};
    for (var result in results) {
      var field = Field.fromMap(result);
      fieldMap[field.fieldConfigId] = field;
    }
    return fieldMap;
  }

  static Future<List<OrderedImage>> orderedImages() async {
    final results = await db!.query(orderedImagesTable);
    return List.generate(
      results.length,
      (index) => OrderedImage.fromMap(results[index]),
    );
  }

  static Future<List<OrderedImage>> orderedImagesByCollectionId(
    int collectionId,
  ) async {
    final results = await db!.query(
      orderedImagesTable,
      where: '$collectionIdColumn = $collectionId',
    );
    return List.generate(
      results.length,
      (index) => OrderedImage.fromMap(results[index]),
    );
  }

  static Future<List<OrderedImage>> orderedImagesByEntryId(int entryId) async {
    final results = await db!.query(
      orderedImagesTable,
      where: '$entryIdColumn = $entryId',
      orderBy: '$indexColumn ASC',
    );
    return List.generate(
      results.length,
      (index) => OrderedImage.fromMap(results[index]),
    );
  }

  static Future<List<Folder>> folders(int collectionId) async {
    String where = '$collectionIdColumn = $collectionId';
    var results = await db!.query(foldersTable, where: where);
    return List.generate(
      results.length,
      (index) => Folder.fromMap(results[index]),
    );
  }

  // ---------------------------------------------------------------------------
  // DB Insert Functions
  // ---------------------------------------------------------------------------

  static Future<int> addCollection(
    Collection collection,
    List<FieldConfig> fieldConfigs,
  ) async {
    int collectionId = await db!.insert(
      collectionsTable,
      removeId(collection.toMap()),
    );
    int idx = 0;
    for (var fieldConfig in fieldConfigs) {
      fieldConfig.collectionId = collectionId;
      fieldConfig.idx = idx++;
      await addFieldConfig(fieldConfig);
    }
    return collectionId;
  }

  static Future<int> addEntry(
    Collection collection,
    Entry entry,
    Map<int, Field> fields,
    List<OrderedImage> images,
    bool wantlist,
  ) async {
    int entryId = await db!.insert(entriesTable, removeId(entry.toMap()));
    for (var field in fields.values) {
      field.entryId = entryId;
      await addField(field);
    }
    int idx = 0;
    for (var image in images) {
      image.entryId = entryId;
      image.idx = idx++;
      await addOrderedImage(image);
    }
    if (wantlist) {
      collection.wantlistSize += 1;
    } else {
      collection.collectionSize += 1;
    }
    await updateCollection(collection);
    return entryId;
  }

  static Future<int> addFieldConfig(FieldConfig fieldConfig) async {
    return await db!.insert(fieldConfigsTable, removeId(fieldConfig.toMap()));
  }

  static Future<int> addField(Field field) async {
    return await db!.insert(fieldsTable, removeId(field.toMap()));
  }

  static Future<int> addOrderedImage(OrderedImage image) async {
    return await db!.insert(orderedImagesTable, removeId(image.toMap()));
  }

  static Future<int> addFolder(Folder folder) async {
    return await db!.insert(foldersTable, removeId(folder.toMap()));
  }

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
      int idx = 0;
      for (var fieldConfig in fieldConfigs) {
        fieldConfig.idx = idx++;
        await updateFieldConfig(fieldConfig);
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
      int idx = 0;
      for (var image in images) {
        image.idx = idx++;
        await updateOrderedImage(image);
      }
      for (var removedImage in removedImages) {
        await removeOrderedImage(removedImage.id);
      }
    }
    if (collection != null) {
      if (prevWantlist != entry.inWantlist) {
        if (entry.inWantlist == 1) {
          collection.collectionSize -= 1;
          collection.wantlistSize += 1;
        } else {
          collection.collectionSize += 1;
          collection.wantlistSize -= 1;
        }
        await updateCollection(collection);
      }
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
      var collectionEntries = await entries(fieldConfig.collectionId);
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

  static Future<void> updateFolder(Folder folder) async {
    await db!.update(foldersTable, folder.toMap());
  }

  // ---------------------------------------------------------------------------
  // DB Delete Functions
  // ---------------------------------------------------------------------------

  static Future<void> removeCollection(int collectionId) async {
    await db!.delete(
      fieldsTable,
      where: '$collectionIdColumn = $collectionId',
    );
    await db!.delete(
      orderedImagesTable,
      where: '$collectionIdColumn = $collectionId',
    );
    await db!.delete(
      fieldConfigsTable,
      where: '$collectionIdColumn = $collectionId',
    );
    await db!.delete(
      entriesTable,
      where: '$collectionIdColumn = $collectionId',
    );
    await db!.delete(
      collectionsTable,
      where: '$idColumn = $collectionId',
    );
  }

  static Future<void> removeEntry(
    Collection collection,
    int entryId,
    bool wantlist,
  ) async {
    await db!.delete(fieldsTable, where: '$entryIdColumn = $entryId');
    await db!.delete(entriesTable, where: '$idColumn = $entryId');
    if (wantlist) {
      collection.wantlistSize -= 1;
    } else {
      collection.collectionSize -= 1;
    }
    await updateCollection(collection);
  }

  static Future<void> removeFieldConfig(int fieldConfigId) async {
    await db!.delete(
      fieldsTable,
      where: '$fieldConfigIdColumn = $fieldConfigId',
    );
    await db!.delete(
      fieldConfigsTable,
      where: '$idColumn = $fieldConfigId',
    );
  }

  static Future<void> removeOrderedImage(int orderedImageId) async {
    await db!.delete(orderedImagesTable, where: '$idColumn = $orderedImageId');
  }

  static Future<void> removeFolder(int folderId) async {
    await db!.delete(foldersTable, where: '$idColumn = $folderId');
  }

  // ---------------------------------------------------------------------------
  // DB Count Functions
  // ---------------------------------------------------------------------------

  static Future<bool> fieldConfigExists(int fieldConfigId) async {
    return await exists(
      fieldConfigsTable,
      where: '$idColumn = $fieldConfigId',
    );
  }

  static Future<bool> orderedImageExists(int orderedImageId) async {
    return await exists(
      orderedImagesTable,
      where: '$idColumn = $orderedImageId',
    );
  }

  static Future<bool> exists(String table, {String where = ''}) async {
    String query = 'SELECT COUNT(1) FROM $table';
    if (where.isNotEmpty) {
      query += ' WHERE $where';
    }
    int? count = Sqflite.firstIntValue(await db!.rawQuery(query));
    return (count ?? 0) > 0;
  }
}
