import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mawaqit/main.dart';
import 'package:uuid/uuid.dart';

class MawaqitImageCache {
  static String? cacheDirectory;

  static Directory getTemporaryDirectory() => Directory.systemTemp;

  static Future<String> urlToKey(String url) async {
    final cacheDirectory = getTemporaryDirectory();
    final key = const Uuid().v5(Uuid.NAMESPACE_URL, url);

    return '${cacheDirectory.path}/image.cache/$key';
  }

  static Future<void> saveImage(String url, List<int> data) async {
    final path = await urlToKey(url);

    final file = File(path);
    await file.create(recursive: true);

    await file.writeAsBytes(data);
  }

  static Future<void> clearAll() async {
    try {
      final cacheDirectory = getTemporaryDirectory();
      await cacheDirectory.delete(recursive: true);
    } catch (e, stack) {
      logger.e('error', e, stack);
    }
  }

  static Future<void> clear(String url) async {
    final path = await urlToKey(url);
    final file = Directory(path);

    file.deleteSync(recursive: true);
  }

  static Future<bool> isImageCached(String url) async {
    final path = await urlToKey(url);
    final file = File(path);

    return await file.exists();
  }

  static Future<Uint8List?> _getLocaleImage(String url) async {
    final path = await urlToKey(url);
    final file = File(path);

    if (await file.exists()) return file.readAsBytes();

    return null;
  }

  static Future<Uint8List> _getUrlImage(String url) async {
    final dio = Dio();

    final response = await dio.get<Uint8List>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) await saveImage(url, response.data!);

    if (response.data == null) throw Exception("image not found");

    if (response.data!.isEmpty) throw Exception("NetworkImage is an empty file: $url");

    return response.data!;
  }

  /// cached image directly without reading it from the hard disk
  /// to gain more performance than [getImage]
  static Future<void> cacheImage(String url) async {
    if (await isImageCached(url)) return;

    await _getUrlImage(url);
  }

  /// get image from cache if exist or from the network
  /// cache the image if not exist
  static Future<Uint8List> getImage(String url) async {
    final localeImage = await _getLocaleImage(url);

    if (localeImage != null) return localeImage;

    return _getUrlImage(url);
  }
}
