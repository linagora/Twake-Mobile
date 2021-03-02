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
  FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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
        AndroidInitializationSettings('logo');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (paload) async {});
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
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  NotificationData messageParse(Map<String, dynamic> message) {
    Map data;
    switch (platform) {
      case Target.Android:
        // logger.d('Android notification received\n$message');
        data = jsonDecode(message['data']['notification_data']);
        break;
      case Target.IOS:
        // logger.d('iOS notification received\n$message');
        data = message['data'];
        break;
      case Target.Linux:
      case Target.MacOS:
      case Target.Windows:
        throw 'Desktop is not supported';
    }
    // logger.d("ok, that's what we have:\n$data");
    MessageNotification notification = MessageNotification.fromJson(data);
    return notification;
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
