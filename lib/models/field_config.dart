import 'package:my_collections/models/my_collections_db.dart';

class FieldConfig {
  int id;
  int collectionId;
  String name;
  int idx;

  FieldConfig({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.idx,
  });

  FieldConfig.create(this.collectionId)
      : id = 0,
        name = '',
        idx = 0;

  FieldConfig copy() => FieldConfig(
        id: id,
        collectionId: collectionId,
        name: name,
        idx: idx,
      );

  Map<String, dynamic> toMap() => {
        idColumn: id,
        collectionIdColumn: collectionId,
        nameColumn: name,
        indexColumn: idx,
      };

  static FieldConfig fromMap(Map<String, dynamic> map) => FieldConfig(
        id: map[idColumn],
        collectionId: map[collectionIdColumn],
        name: map[nameColumn],
        idx: map[indexColumn],
      );
}
