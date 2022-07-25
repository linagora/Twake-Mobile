import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/utils/constants.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twake/widgets/common/button_text_builder.dart';
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
    var appUrl =
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    if (Platform.isIOS) {
      appUrl = 'https://itunes.apple.com/app/$IOS_APPSTORE_ID';
    }
    await Share.share(appUrl);
  }

  static void showSimpleSnackBar(
      {required BuildContext context,
      required String message,
      String? iconPath,
      Duration? duration,
      IconData? iconData}) {
    Get.snackbar('', '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        animationDuration: Duration(milliseconds: 300),
        duration: duration ?? const Duration(milliseconds: 1500),
        icon: iconPath != null
            ? Image.asset(iconPath, width: 40, height: 40)
            : null,
        titleText: SizedBox.shrink(),
        messageText: Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              iconData == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(
                        iconData,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
              Text(message,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 14)),
            ],
          ),
        ),
        boxShadows: [
          BoxShadow(
            blurRadius: 16,
            color: Color.fromRGBO(0, 0, 0, 0.24),
          )
        ]);
  }

  static void showLimitDialog(
      {required BuildContext context,
      required String message,
      required String titleText,
      String? iconPath,
      String? buttonText1,
      String? buttonText2,
      Function? onButtonClick1,
      Function? onButtonClick2,
      Duration? duration}) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Get.theme.colorScheme.secondaryContainer,
          insetPadding: EdgeInsets.all(
            Dim.widthPercent(3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: Dim.heightPercent(60),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim.widthPercent(5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      radius: 40,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          imageUsers,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AutoSizeText(
                      titleText,
                      style: Get.theme.textTheme.headline1!
                          .copyWith(fontSize: 24, fontWeight: FontWeight.w600),
                      minFontSize: 20,
                    ),
                  ),
                  AutoSizeText(
                    message,
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.headline2!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                    minFontSize: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: ButtonTextBuilder(
                      Key('button_1'),
                      onButtonClick: onButtonClick1,
                      backgroundColor: Get.theme.colorScheme.surface,
                    )
                        .setWidth(double.infinity)
                        .setHeight(50)
                        .setText(buttonText1 ?? '')
                        .setTextStyle(Get.isDarkMode
                            ? Get.theme.textTheme.headline1!.copyWith(
                                fontSize: 17, fontWeight: FontWeight.w600)
                            : Get.theme.textTheme.bodyText1!.copyWith(
                                fontSize: 17, fontWeight: FontWeight.w500))
                        .build(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: ButtonTextBuilder(
                      Key('button_2'),
                      onButtonClick: onButtonClick2,
                      backgroundColor: Get.isDarkMode
                          ? Get.theme.backgroundColor
                          : Get.theme.colorScheme.secondary,
                    )
                        .setWidth(double.infinity)
                        .setHeight(50)
                        .setText(buttonText2 ?? '')
                        .setTextStyle(Get.isDarkMode
                            ? Get.theme.textTheme.headline1!.copyWith(
                                fontSize: 17, fontWeight: FontWeight.w600)
                            : Get.theme.textTheme.bodyText1!.copyWith(
                                fontSize: 17, fontWeight: FontWeight.w500))
                        .build(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> _isNeedRequestStoragePermissionOnAndroid(
      {required PermissionStorageType permissionType}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (permissionType == PermissionStorageType.WriteExternalStorage) {
      return androidInfo.version.sdkInt <= 29;
    }
    if (permissionType == PermissionStorageType.ReadExternalStorage) {
      return true;
    }
    return false;
  }

  static Future<bool> checkAndRequestStoragePermission({
    required PermissionStorageType permissionType,
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    if (Platform.isIOS) {
      onGranted?.call();
      return true;
    }
    final needRequestPermission =
        await _isNeedRequestStoragePermissionOnAndroid(
            permissionType: permissionType);
    if (Platform.isAndroid && needRequestPermission) {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted:
          onGranted?.call();
          return true;
        case PermissionStatus.permanentlyDenied:
          onPermanentlyDenied?.call();
          return false;
        default:
          {
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

  static Future<bool> checkCameraPermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final status = await Permission.camera.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        return false;
    }
  }

  static Future<bool> requestCameraPermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final requested = await Permission.camera.request();
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

  static Future<bool> checkAndRequestPhotoPermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    // For Android, no need grant Photo permission,
    // because GallerySaver used MediaStore internally
    if (Platform.isAndroid) {
      onGranted?.call();
      return true;
    }
    final status = await Permission.photos.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        {
          final requested = await Permission.photos.request();
          switch (requested) {
            case PermissionStatus.granted:
              onGranted?.call();
              return true;
            case PermissionStatus.denied:
              onDenied?.call();
              return false;
            case PermissionStatus.permanentlyDenied:
              onPermanentlyDenied?.call();
              return false;
            default:
              onDenied?.call();
              return false;
          }
        }
    }
  }

  static Future<bool> checkPhotoPermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final status = await Permission.photos.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        return false;
    }
  }

  static Future<List<PlatformFile>?> pickFiles(
      {required BuildContext context, required FileType fileType}) async {
    final isGranted = await Utilities.checkAndRequestStoragePermission(
        permissionType: PermissionStorageType.ReadExternalStorage,
        onPermanentlyDenied: () => showOpenSettingsDialog(context: context));
    if (!isGranted) return null;
    List<PlatformFile>? _paths;
    try {
      _paths = (await FilePicker.platform
              .pickFiles(type: fileType, allowMultiple: true, withData: true))
          ?.files;
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
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  fontSize: 18.0,
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

  static String preprocessString(dynamic input) {
    return input != null ? input.toString() : '';
  }

  static bool isTwakeLink(String url) {
    final launchUri = Uri.parse(url.trim());
    final host = launchUri.host;
    return Endpoint.inSupportedHosts(host);
  }
}

enum PermissionStorageType {
  ReadExternalStorage,
  WriteExternalStorage,
}
