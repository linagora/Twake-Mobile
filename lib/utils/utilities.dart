import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';
import 'package:twake/utils/constants.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/widgets/common/confirm_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  static void showSimpleSnackBar({required String message, String? iconPath}) {
    Get.snackbar('', '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        animationDuration: Duration(milliseconds: 300),
        duration: const Duration(milliseconds: 1500),
        icon: iconPath != null ? Image.asset(iconPath, width: 40, height: 40) : null,
        titleText: SizedBox.shrink(),
        messageText: Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Text(message,
              style: StylesConfig.commonTextStyle.copyWith(fontSize: 15)),

        ),
        boxShadows: [
          BoxShadow(
            blurRadius: 16,
            color: Color.fromRGBO(0, 0, 0, 0.24),
          )
        ]
    );
  }

  static Future<bool> _isNeedRequestStoragePermissionOnAndroid(
      {required PermissionStorageType permissionType}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if(permissionType == PermissionStorageType.WriteExternalStorage) {
      return androidInfo.version.sdkInt <= 28;
    }
    if(permissionType == PermissionStorageType.ReadExternalStorage) {
      return true;
    }
    return false;
  }

  static Future<bool> checkAndRequestPermission({
    required PermissionStorageType permissionType,
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    if(Platform.isIOS) {
      onGranted?.call();
      return true;
    }
    final needRequestPermission =
        await _isNeedRequestStoragePermissionOnAndroid(permissionType: permissionType);
    if(Platform.isAndroid && needRequestPermission) {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted:
          onGranted?.call();
          return true;
        case PermissionStatus.permanentlyDenied:
          onPermanentlyDenied?.call();
          return false;
        default: {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted:
              onGranted?.call();
              return true;
            case PermissionStatus.permanentlyDenied:
              onPermanentlyDenied?.call();
              return false;
            default:
              onDenied?.call();
              return false;
          }
        }
      }
    } else {
      onGranted?.call();
      return true;
    }
  }

  static Future<List<PlatformFile>?> pickFiles({required BuildContext context, required FileType fileType}) async {
    final isGranted = await Utilities.checkAndRequestPermission(
      permissionType: PermissionStorageType.ReadExternalStorage,
      onPermanentlyDenied: () => showOpenSettingsDialog(context: context)
    );
    if(!isGranted)
      return null;
    List<PlatformFile>? _paths;
    try {
      _paths = (await FilePicker.platform.pickFiles(
          type: fileType,
          allowMultiple: true))?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
      return null;
    } catch (e) {
      Logger().e('Error occurred during picking file:\n$e');
      return null;
    }
    return _paths;
  }

  static showOpenSettingsDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          body: Text(
            AppLocalizations.of(context)?.openSettingsMessage ?? '',
            style: StylesConfig.commonTextStyle.copyWith(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          cancelActionTitle: AppLocalizations.of(context)?.deny ?? '',
          okActionTitle: AppLocalizations.of(context)?.openSettings ?? '',
          okAction: () => openAppSettings(),
        );
      },
    );
  }

}

enum PermissionStorageType {
  ReadExternalStorage,
  WriteExternalStorage,
}