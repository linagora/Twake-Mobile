import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformDetection {
  static SupportedPlatform detectPlatform() {
    if (kIsWeb) {
      return SupportedPlatform.Web;
    }
    if (Platform.isAndroid) {
      return SupportedPlatform.Android;
    }
    if (Platform.isIOS) {
      return SupportedPlatform.iOS;
    }
    if (Platform.isMacOS) {
      return SupportedPlatform.MacOS;
    }
    if (Platform.isLinux) {
      return SupportedPlatform.Linux;
    }
    if (Platform.isWindows) {
      return SupportedPlatform.Windows;
    }
    return SupportedPlatform.Unknown;
  }

  static bool isMobileSupported() {
    if(kIsWeb)
      return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isMagicLinkSupported() {
    if(kIsWeb)
      return true;
    return Platform.isAndroid || Platform.isIOS;
  }

  void dbLayerByPlatform({
    Function? webImpl,
    Function? androidImpl,
    Function? iOSImpl,
    Function? macOSImpl,
    Function? windowsImpl,
    Function? linuxImpl,
    Function? otherImpl,
  }) {
    switch (PlatformDetection.detectPlatform()) {
      case SupportedPlatform.Web:
        webImpl?.call();
        break;
      case SupportedPlatform.Android:
        androidImpl?.call();
        break;
      case SupportedPlatform.iOS:
        iOSImpl?.call();
        break;
      case SupportedPlatform.MacOS:
        macOSImpl?.call();
        break;
      case SupportedPlatform.Windows:
        windowsImpl?.call();
        break;
      case SupportedPlatform.Linux:
        linuxImpl?.call();
        break;
      default:
        otherImpl?.call();
        break;
    }
  }
}

enum SupportedPlatform { Android, iOS, Web, MacOS, Linux, Windows, Unknown }
