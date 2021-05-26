import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:twake/models/push_notification/firebase_notification.dart';

export 'package:twake/models/push_notification/firebase_notification.dart';

class PushNotificationsService {
  static late PushNotificationsService _service;
  late final FirebaseMessaging _firebase;
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  factory PushNotificationsService({required bool reset}) {
    if (reset) {
      _service = PushNotificationsService._();
    }
    return _service;
  }

  PushNotificationsService._() {
    // Get firebase instance
    _firebase = FirebaseMessaging.instance;

    //  Get local notifications plugin instance
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Set up local notifications settings
    // ic_notification can be swapped for another drawable resource
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: IOSInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    );

    // BIG TODO: Figure out how to get access to
    // user clicks on local notifications without resorting to callbacks
    // on initialize method of the plugin

    // Initialize the local notifications plugin with above settings
    _notificationsPlugin.initialize(initSettings);
  }

  static PushNotificationsService get instance => _service;

  void requestPermission() async {
    // Request permissions for firebase
    if (Platform.isIOS) await _firebase.requestPermission();

    // Request permissions for local notifications
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          sound: true,
          alert: true,
          badge: true,
        );
  }

  // Returns a stream of notifications received,
  // while the application is in the foreground
  Stream<FirebaseMessage> get foregroundMessageStream {
    return FirebaseMessaging.onMessage.map(_transform);
  }

  // Returns a stream of notifications which was pressed on,
  // while the application was in background
  Stream<FirebaseMessage> get notificationClickStream {
    return FirebaseMessaging.onMessageOpenedApp.map(_transform);
  }

  // Should be called to check whether the app was started up
  // (from terminated state) via user click on notification
  Future<FirebaseMessage?> get checkForNotificationClick async {
    final remoteMessage = await _firebase.getInitialMessage();

    if (remoteMessage == null) return null;

    return FirebaseMessage.fromRemote(remoteMessage: remoteMessage);
  }

  void showLocal() {
    // logic for showing any kind of local notification
  }

  FirebaseMessage _transform(RemoteMessage msg) {
    return FirebaseMessage.fromRemote(remoteMessage: msg);
  }
}

class PendingNotifications {
  final List<int> _ids = [];
  PendingNotifications();
}
