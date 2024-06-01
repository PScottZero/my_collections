import 'dart:io';
import 'dart:typed_data';

import 'package:my_collections/models/my_collections_db.dart';
import 'package:my_collections/models/ordered_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const String downloadPath = '/storage/emulated/0/Download';
const String documentsPath = '/storage/emulated/0/Documents';
const String backupPath = '$documentsPath/MyCollectionsBU';
const String backupImagesPath = '$backupPath/images';
const String backupDBPath = '$backupPath/${MyCollectionsDB.dbName}';

class MyCollectionsLocalStorage {
  static String localPath = '';
  static String get localImagesPath => '$localPath/images';

  static Future<void> init() async {
    localPath = (await getApplicationDocumentsDirectory()).path;
  }

  // ---------------------------------------------------------------------------
  // Load / Save / Delete Full Resolution Images
  // ---------------------------------------------------------------------------

  static Future<Map<String, Uint8List>> loadImages(
    List<OrderedImage> images,
  ) async {
    Map<String, Uint8List> imageData = {};
    for (var image in images) {
      var bytes = await loadImage(image.image);
      imageData[image.image] = bytes;
    }
    return imageData;
  }

  static Future<void> saveImages(
    List<OrderedImage> images,
    Map<String, Uint8List> imageData,
  ) async {
    for (var image in images) {
      var bytes = imageData[image.image];
      if (bytes != null) {
        await saveImage(image.image, bytes);
      }
    }
  }

  static Future<void> deleteImages(List<OrderedImage> removedImages) async {
    for (var image in removedImages) {
      await deleteImage(image.image);
    }
  }

  static Future<Uint8List> loadImage(String image) async {
    var file = File('$localImagesPath/$image');
    var bytes = Uint8List.fromList([]);
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      // do nothing
    }
    return bytes;
  }

  static Future<void> saveImage(String image, Uint8List bytes) async {
    var file = File('$localImagesPath/$image');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  static Future<void> deleteImage(String image) async {
    var file = File('$localImagesPath/$image');
    try {
      await file.delete();
    } catch (e) {
      // do nothing
    }
  }

  static Future<void> downloadImage(String image, Uint8List bytes) async {
    if (await requestStoragePermissions()) {
      final imageDir = '$downloadPath/$image';
      final file = File(imageDir);
      await file.writeAsBytes(bytes);
    }
  }

  // ---------------------------------------------------------------------------
  // Backup + Restore
  // ---------------------------------------------------------------------------

  static Future<String> backup() async {
    if (await requestStoragePermissions()) {
      // create backup directory
      final backupDir = Directory(backupImagesPath);
      await backupDir.create(recursive: true);

      // backup database
      final dbFile = File(await MyCollectionsDB.dbPath);
      await dbFile.copy(backupDBPath);

      // backup images
      final localImagesDir = Directory(localImagesPath);
      await for (var file in localImagesDir.list()) {
        final imageName = file.path.split('/').last;
        final imageFile = File(file.path);
        await imageFile.copy('$backupImagesPath/$imageName');
      }

      return 'Backup complete';
    }
    return 'Permissions error';
  }

  static Future<String> restore() async {
    if (await requestStoragePermissions()) {
      final backupDir = Directory(backupPath);
      final backupImagesDir = Directory(backupImagesPath);
      final backupDBFile = File(backupDBPath);

      // check if backup directories exists
      if (!(await backupDir.exists())) {
        return 'No backup found';
      }
      if (!(await backupImagesDir.exists())) {
        return 'Could not find backup images folder';
      }
      if (!(await backupDBFile.exists())) {
        return 'Could not find backup database file';
      }

      // load backup database
      await backupDBFile.copy(await MyCollectionsDB.dbPath);

      // clear current images directory
      final localImagesDir = Directory(localImagesPath);
      if (await localImagesDir.exists()) {
        await localImagesDir.delete(recursive: true);
      }
      await localImagesDir.create();

      // load backup images
      await for (var file in backupImagesDir.list()) {
        final fileName = file.path.split('/').last;
        final imageFile = File(file.path);
        await imageFile.copy('$localImagesPath/$fileName');
      }

      return 'Successfully restored data';
    }
    return 'Permissions error';
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  static Future<bool> requestStoragePermissions() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }
}
