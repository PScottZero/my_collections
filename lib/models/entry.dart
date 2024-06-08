import 'dart:typed_data';

import 'package:my_collections/models/mc_db.dart';

class Entry {
  int id;
  int collectionId;
  String name;
  String value;
  Uint8List thumbnail;
  int inWantlist;
  DateTime createdAt;

  String get formattedValue => valueStr(floatValue);
  double get floatValue => parseValue(value);

  Entry({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.value,
    required this.thumbnail,
    required this.inWantlist,
    required this.createdAt,
  });

  static double parseValue(String value) {
    return double.tryParse(value.replaceAll('\$', '').trim()) ?? 0;
  }

  static String valueStr(double value) {
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

  Entry.create(this.collectionId)
      : id = 0,
        name = '',
        value = '',
        thumbnail = Uint8List.fromList([]),
        inWantlist = 0,
        createdAt = DateTime.now();

  Entry copy() => Entry(
        id: id,
        collectionId: collectionId,
        name: name,
        value: value,
        thumbnail: thumbnail,
        inWantlist: inWantlist,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        idColumn: id,
        collectionIdColumn: collectionId,
        nameColumn: name,
        valueColumn: value,
        thumbnailColumn: thumbnail,
        inWantlistColumn: inWantlist,
        createdAtColumn: createdAt.toString(),
      };

  static Entry fromMap(Map<String, dynamic> map) => Entry(
        id: map[idColumn],
        collectionId: map[collectionIdColumn],
        name: map[nameColumn],
        value: map[valueColumn],
        thumbnail: map[thumbnailColumn] ?? Uint8List.fromList([]),
        inWantlist: map[inWantlistColumn],
        createdAt: DateTime.parse(map[createdAtColumn]),
      );
}
