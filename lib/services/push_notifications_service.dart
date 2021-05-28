import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:twake/models/push_notification/firebase_notification.dart';
import 'package:twake/models/push_notification/local_notification.dart';

export 'package:twake/models/push_notification/firebase_notification.dart';

class PushNotificationsService {
  static late PushNotificationsService _service;
  late final FirebaseMessaging _firebase;
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final StreamController<LocalNotification> _localNotificationClickStream =
      StreamController();

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

    // Initialize the local notifications plugin with above settings
    _notificationsPlugin.initialize(
      initSettings,
      onSelectNotification: _onLocalNotificationSelect,
    );
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

  // Returns a stream of events when user clicks on local notifications
  Stream<LocalNotification> get localNotifications =>
      _localNotificationClickStream.stream;

  // Should be called to check whether the app was started up
  // (from terminated state) via user click on notification
  Future<FirebaseMessage?> get checkRemoteNotificationClick async {
    final remoteMessage = await _firebase.getInitialMessage();

    if (remoteMessage == null) return null;

    return FirebaseMessage.fromRemote(remoteMessage: remoteMessage);
  }

  Future<LocalNotification?> get checkLocalNotificationClick async {
    final details =
        await _notificationsPlugin.getNotificationAppLaunchDetails();

    // Not null guaranteed on android and iOS
    if (!details!.didNotificationLaunchApp) return null;

    final payload = details.payload;
    if (payload != null) {
      return LocalNotification.fromEncodedString(string: payload);
    }

    return null;
  }

  // Delivers local notification, and returns its ID
  int showLocal({
    required String title,
    required String body,
    String? payload,
  }) {
    const android = const AndroidNotificationDetails('Twake', 'Twake', 'Twake');
    const details = NotificationDetails(android: android);
    final id = DateTime.now().millisecondsSinceEpoch;

    _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    return id;
  }

  Future<void> cancelLocal({required int id}) =>
      _notificationsPlugin.cancel(id);

  FirebaseMessage _transform(RemoteMessage msg) {
    return FirebaseMessage.fromRemote(remoteMessage: msg);
  }

  Future<void> _onLocalNotificationSelect(String? payload) async {
    if (payload == null) return;

    final notification = LocalNotification.fromEncodedString(string: payload);

    _localNotificationClickStream.sink.add(notification);
  }

  Future<void> dispose() async {
    await _localNotificationClickStream.close();
  }
}
