import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';
import 'package:twake/utils/constants.dart';

class Utilities {

  // Use this to get cached path from image that downloaded by cached_network_image
  // FYI: https://pub.dev/packages/cached_network_image#how-it-works
  static Future<String> getCachedImagePath(String imageUrl) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    return file.path;
  }

  static void shareApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var appUrl = 'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    if(Platform.isIOS) {
      appUrl = 'https://itunes.apple.com/app/$IOS_APPSTORE_ID';
    }
    await Share.share(appUrl);
  }


}