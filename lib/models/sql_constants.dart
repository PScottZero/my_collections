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
