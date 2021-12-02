import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Utilities {

  // Use this to get cached path from image that downloaded by cached_network_image
  // FYI: https://pub.dev/packages/cached_network_image#how-it-works
  static Future<String> getCachedImagePath(String imageUrl) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    return file.path;
  }

}