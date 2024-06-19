import 'package:my_collections/models/sql_constants.dart';

class OrderedImage {
  int id;
  int collectionId;
  int entryId;
  String image;
  int idx;

  OrderedImage({
    required this.id,
    required this.collectionId,
    required this.entryId,
    required this.image,
    required this.idx,
  });

  OrderedImage.create(this.collectionId, this.entryId, this.image)
      : id = 0,
        idx = 0;

  OrderedImage copy() => OrderedImage(
        id: id,
        collectionId: collectionId,
        entryId: entryId,
        image: image,
        idx: idx,
      );

  Map<String, dynamic> toMap() => {
        idColumn: id,
        collectionIdColumn: collectionId,
        entryIdColumn: entryId,
        imageColumn: image,
        indexColumn: idx,
      };

  static OrderedImage fromMap(Map<String, dynamic> map) => OrderedImage(
        id: map[idColumn],
        collectionId: map[collectionIdColumn],
        entryId: map[entryIdColumn],
        image: map[imageColumn],
        idx: map[indexColumn],
      );
}
