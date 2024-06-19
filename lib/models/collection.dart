import 'dart:typed_data';

import 'package:my_collections/models/sql_constants.dart';

class Collection {
  int id;
  String name;
  String value;
  Uint8List thumbnail;
  int collectionSize;
  int wantlistSize;
  DateTime createdAt;

  Collection({
    required this.id,
    required this.name,
    required this.value,
    required this.thumbnail,
    required this.collectionSize,
    required this.wantlistSize,
    required this.createdAt,
  });

  Collection.create()
      : id = 0,
        name = '',
        value = '',
        thumbnail = Uint8List.fromList([]),
        collectionSize = 0,
        wantlistSize = 0,
        createdAt = DateTime.now();

  Collection copy() => Collection(
        id: id,
        name: name,
        value: value,
        thumbnail: thumbnail,
        collectionSize: collectionSize,
        wantlistSize: wantlistSize,
        createdAt: createdAt,
      );

  void incrementSize(bool wantlist) =>
      wantlist ? wantlistSize += 1 : collectionSize += 1;

  void decrementSize(bool wantlist) =>
      wantlist ? wantlistSize -= 1 : collectionSize -= 1;

  void toggleSize(bool wantlist) {
    if (wantlist) {
      collectionSize -= 1;
      wantlistSize += 1;
    } else {
      collectionSize += 1;
      wantlistSize -= 1;
    }
  }

  Map<String, dynamic> toMap() => {
        idColumn: id,
        nameColumn: name,
        valueColumn: value,
        thumbnailColumn: thumbnail,
        collectionSizeColumn: collectionSize,
        wantlistSizeColumn: wantlistSize,
        createdAtColumn: createdAt.toString(),
      };

  static Collection fromMap(Map<String, dynamic> map) => Collection(
        id: map[idColumn],
        name: map[nameColumn],
        value: map[valueColumn],
        thumbnail: map[thumbnailColumn],
        collectionSize: map[collectionSizeColumn],
        wantlistSize: map[wantlistSizeColumn],
        createdAt: DateTime.parse(map[createdAtColumn]),
      );
}
