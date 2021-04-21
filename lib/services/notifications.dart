import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twake/models/notification.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  final logger = Logger();
  Target platform;
  final Function(MessageNotification) onMessageCallback;
  final Function(MessageNotification) onResumeCallback;
  final Function(MessageNotification) onLaunchCallback;
  final bool Function(MessageNotification) shouldNotify;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<String, List<int>> pendingNotifications = {};
  var counter = 0;

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    print('SHOW IOS NOTIFICATION');
  }

  Notifications({
    this.onMessageCallback,
    this.onResumeCallback,
    this.onLaunchCallback,
    this.shouldNotify,
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
    FirebaseMessaging.onMessage.listen(onMessage);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher_foreground');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      print("PAYLOAD FROM NOTIFY: $payload");
      final map = jsonDecode(payload);
      print("NOTIFY CLICK: $map");
      try {
        final notification = MessageNotification.fromJson(map);
        print("NOTIFICATION PARSED: $notification");
        onMessageCallback(notification);
      } catch (e) {
        logger.wtf('ERROR PARSING NOTIFY: $e');
      }
    });
  }

  Future<dynamic> onMessage(RemoteMessage rmessage) async {
    Map<String, dynamic> message = rmessage.data;
    logger.d('GOT MESSAGE FROM FIREBASE: $message, ${rmessage.toString()}');
    final notification = messageParse(message);
    if (!shouldNotify(notification)) return;
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'some-random-text', 'Twake', 'Twake Mobile App',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final channelId = _getChannelId(message);

    if (pendingNotifications[channelId] == null) {
      pendingNotifications[channelId] = [];
    }
    pendingNotifications[channelId].add(counter);

    await flutterLocalNotificationsPlugin.show(
      counter,
      rmessage.notification.title,
      rmessage.notification.body,
      platformChannelSpecifics,
      payload: _getPayload(message),
    );
    counter++;
  }

  Future<void> cancelNotificationForChannel(String channelId) async {
    final channelNotifications = pendingNotifications[channelId];
    if (channelNotifications == null) return;
    for (var n in channelNotifications) {
      await flutterLocalNotificationsPlugin.cancel(n);
    }
    pendingNotifications.remove(channelId);
    if (pendingNotifications.isEmpty) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  Future<void> cancelAll() async {
    pendingNotifications = {};
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  MessageNotification messageParse(Map<String, dynamic> message) {
    // logger.d("ok, that's what we have:\n$data");
    final data = jsonDecode(_getPayload(message));
    MessageNotification notification = MessageNotification.fromJson(data);
    return notification;
  }

  // String _getBody(Map<String, dynamic> message) {
  // var data;
  // switch (platform) {
  // case Target.Android:
  // logger.d('Android notification received\n$message');
  // data = message['body'];
  // break;
  // case Target.IOS:
  // logger.d('iOS notification received\n$message');
  // data = message['aps']['alert']['body'];
  // break;
  // case Target.Linux:
  // case Target.MacOS:
  // case Target.Windows:
  // throw 'Desktop is not supported';
  // }
  // return data;
  // }
//
  // String _getTitle(Map<String, dynamic> message) {
  // var data;
  // switch (platform) {
  // case Target.Android:
  // logger.d('Android notification received\n$message');
  // data = message['title'];
  // break;
  // case Target.IOS:
  // logger.d('iOS notification received\n$message');
  // data = message['aps']['alert']['title'];
  // break;
  // case Target.Linux:
  // case Target.MacOS:
  // case Target.Windows:
  // throw 'Desktop is not supported';
  // }
  // return data;
  // }

  String _getPayload(Map<String, dynamic> message) {
    var data;
    switch (platform) {
      case Target.Android:
        // logger.d('Android notification received\n$message');
        data = message['notification_data'];
        break;
      case Target.IOS:
        // logger.d('iOS notification received\n$message');
        data = message['notification_data'];
        break;
      case Target.Linux:
      case Target.MacOS:
      case Target.Windows:
        throw 'Desktop is not supported';
    }
    if (data.runtimeType == Map) {
      return jsonEncode(data);
    }
    return data;
  }

  String _getChannelId(Map<String, dynamic> message) {
    var data;
    switch (platform) {
      case Target.Android:
        // logger.d('Android notification received\n$message');
        data = message['notification_data'];
        break;
      case Target.IOS:
        // logger.d('iOS notification received\n$message');
        data = message['notification_data'];
        break;
      case Target.Linux:
      case Target.MacOS:
      case Target.Windows:
        throw 'Desktop is not supported';
    }
    if (data.runtimeType == String) {
      return jsonDecode(data)['channel_id'];
    }
    return data['channel_id'];
  }

  // Future<dynamic> onResume(RemoteMessage rmessage) async {
  // Map<String, dynamic> message = rmessage.data;
  // logger.d('Resuming on message received\n$message');
  // final notification = messageParse(message);
  // await onResumeCallback(notification);
  // }

  // Future<dynamic> onLaunch(RemoteMessage message) async {
  // onResume(message);
  // }
}

enum Target {
  Android,
  IOS,
  Linux,
  MacOS,
  Windows,
}
