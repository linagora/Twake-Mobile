import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
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
  FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<String, List<int>> pendingNotifications = {};
  var counter = 0;
  // final _api = Api();
// Future onDidReceiveLocalNotification(
  // int id, String title, String body, String payload) async {
  // // display a dialog with the notification details, tap ok to go to another page
  // showDialog(
  // context: context,
  // builder: (BuildContext context) => CupertinoAlertDialog(
  // title: Text(title),
  // content: Text(body),
  // actions: [
  // CupertinoDialogAction(
  // isDefaultAction: true,
  // child: Text('Ok'),
  // onPressed: () async {
  // Navigator.of(context, rootNavigator: true).pop();
  // await Navigator.push(
  // context,
  // MaterialPageRoute(
  // builder: (context) => SecondScreen(payload),
  // ),
  // );
  // },
  // )
  // ],
  // ),
  // );
// }

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
    _fcm.configure(
      onMessage: onMessage,
      onResume: onResume,
      onLaunch: onLaunch,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logo_blue');
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

  // Future<void> checkWhatsNew(String workspaceId) async {
  // final List<dynamic> news = await _api.get(
  // Endpoint.whatsNew,
  // params: {
  // 'company_id': ProfileBloc.selectedCompany,
  // 'workspace_id': workspaceId
  // },
  // );
  // for (Map item in news) {
  // final update = WhatsNewItem.fromJson(item);
  // }
  // }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    logger.d('GOT MESSAGE FROM FIREBASE: $message');
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
      _getTitle(message),
      _getBody(message),
      platformChannelSpecifics,
      payload: _getPayload(message),
    );
    counter++;
  }

  Future<void> cancelNotificationForChannel(String channelId) async {
    final channelNotifications = pendingNotifications[channelId];
    if (channelNotifications == null) return;
    for (var n in channelNotifications)
      await flutterLocalNotificationsPlugin.cancel(n);
  }

  MessageNotification messageParse(Map<String, dynamic> message) {
    // logger.d("ok, that's what we have:\n$data");
    final data = jsonDecode(_getPayload(message));
    MessageNotification notification = MessageNotification.fromJson(data);
    return notification;
  }

  String _getBody(Map<String, dynamic> message) {
    var data;
    switch (platform) {
      case Target.Android:
        // logger.d('Android notification received\n$message');
        data = message['notification']['body'];
        break;
      case Target.IOS:
        // logger.d('iOS notification received\n$message');
        data = message['apps']['alert']['body'];
        break;
      case Target.Linux:
      case Target.MacOS:
      case Target.Windows:
        throw 'Desktop is not supported';
    }
    return data;
  }

  String _getTitle(Map<String, dynamic> message) {
    var data;
    switch (platform) {
      case Target.Android:
        // logger.d('Android notification received\n$message');
        data = message['notification']['title'];
        break;
      case Target.IOS:
        // logger.d('iOS notification received\n$message');
        data = message['apps']['alert']['title'];
        break;
      case Target.Linux:
      case Target.MacOS:
      case Target.Windows:
        throw 'Desktop is not supported';
    }
    return data;
  }

  String _getPayload(Map<String, dynamic> message) {
    var data;
    switch (platform) {
      case Target.Android:
        // logger.d('Android notification received\n$message');
        data = message['data']['notification_data'];
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
        data = message['data']['notification_data'];
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

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    logger.d('Resuming on message received\n$message');
    final notification = messageParse(message);
    // logger.d("ok, that's what we have:\n$notification");
    await onResumeCallback(notification);
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
