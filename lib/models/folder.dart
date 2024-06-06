import 'dart:typed_data';

import 'package:my_collections/models/mc_db.dart';

class Folder {
  int id;
  int collectionId;
  String name;
  String value;
  Uint8List thumbnail;
  int collectionSize;
  int wantlistSize;
  DateTime createdAt;

  Folder({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.value,
    required this.thumbnail,
    required this.collectionSize,
    required this.wantlistSize,
    required this.createdAt,
  });

  Folder.create(this.collectionId)
      : id = 0,
        name = '',
        value = '',
        thumbnail = Uint8List.fromList([]),
        collectionSize = 0,
        wantlistSize = 0,
        createdAt = DateTime.now();

  Folder copy() => Folder(
        id: id,
        collectionId: collectionId,
        name: name,
        value: value,
        thumbnail: thumbnail,
        collectionSize: collectionSize,
        wantlistSize: wantlistSize,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        idColumn: id,
        collectionIdColumn: collectionId,
        nameColumn: name,
        valueColumn: value,
        thumbnailColumn: thumbnail,
        collectionSizeColumn: collectionSize,
        wantlistSizeColumn: wantlistSize,
        createdAtColumn: createdAt.toString(),
      };

  static Folder fromMap(Map<String, dynamic> map) => Folder(
        id: map[idColumn],
        collectionId: map[collectionIdColumn],
        name: map[nameColumn],
        value: map[valueColumn],
        thumbnail: map[thumbnailColumn],
        collectionSize: map[collectionSizeColumn],
        wantlistSize: map[wantlistSizeColumn],
        createdAt: DateTime.parse(map[createdAtColumn]),
      );
}
