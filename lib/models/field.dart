import 'package:my_collections/models/sql_constants.dart';

class Field {
  int id;
  int collectionId;
  int entryId;
  int fieldConfigId;
  String value;

  Field({
    required this.id,
    required this.collectionId,
    required this.entryId,
    required this.fieldConfigId,
    required this.value,
  });

  Field.create(this.collectionId, this.fieldConfigId, {this.entryId = 0})
      : id = 0,
        value = '';

  Field copy() => Field(
        id: id,
        collectionId: collectionId,
        entryId: entryId,
        fieldConfigId: fieldConfigId,
        value: value,
      );

  Map<String, dynamic> toMap() => {
        idColumn: id,
        collectionIdColumn: collectionId,
        entryIdColumn: entryId,
        fieldConfigIdColumn: fieldConfigId,
        valueColumn: value,
      };

  static Field fromMap(Map<String, dynamic> map) => Field(
        id: map[idColumn],
        collectionId: map[collectionIdColumn],
        entryId: map[entryIdColumn],
        fieldConfigId: map[fieldConfigIdColumn],
        value: map[valueColumn],
      );
}
