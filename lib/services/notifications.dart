import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:twake_mobile/models/notification.dart';

class Notifications {
  final logger = Logger();
  Target platform;
  final Function(NotificationData) onMessageCallback;
  final Function(NotificationData) onResumeCallback;
  final Function(NotificationData) onLaunchCallback;
  FirebaseMessaging _fcm = FirebaseMessaging();

  Notifications({
    this.onMessageCallback,
    this.onResumeCallback,
    this.onLaunchCallback,
  }) {
    if (Platform.isAndroid)
      this.platform = Target.Android;
    else if (Platform.isIOS)
      this.platform = Target.IOS;
    else if (Platform.isLinux)
      this.platform = Target.Linux;
    else if (Platform.isMacOS)
      this.platform = Target.MacOS;
    else if (Platform.isWindows) this.platform = Target.Windows;
    _fcm.configure(
      onMessage: onMessage,
    );
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    final notification = messageParse(message);
    onMessageCallback(notification);
  }

  NotificationData messageParse(Map<String, dynamic> message) {
    Map data;
    switch (platform) {
      case Target.Android:
        logger.d('Android notification received\n$message');
        data = jsonDecode(message['data']['notification_data']);
        break;
      case Target.IOS:
        logger.d('iOS notification received\n$message');
        data = message['data'];
        break;
      case Target.Linux:
      case Target.MacOS:
      case Target.Windows:
        throw 'Desktop is not supported';
    }
    logger.d("ok, that's what we have:\n$data");
    MessageNotification notification = MessageNotification.fromJson(data);
    // Monkey patch TODO burn this piece of code
    // https://github.com/TwakeApp/Mobile/issues/99
    if (notification.channelId[14] == '1') {
      notification.channelId = notification.channelId.replaceRange(14, 15, '4');
    }
    return notification;
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    logger.d('Resuming on message received\n$message');
    final notification = messageParse(message);
    onResumeCallback(notification);
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    onResume(message);
  }
}

enum Target {
  Android,
  IOS,
  Linux,
  MacOS,
  Windows,
}
