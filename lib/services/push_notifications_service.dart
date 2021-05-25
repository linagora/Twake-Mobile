import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twake/models/push_notification/firebase_notification.dart';

class PushNotificationsService {
  static late PushNotificationsService _service;
  late final FirebaseMessaging _firebase;

  factory PushNotificationsService({required bool reset}) {
    if (reset) {
      _service = PushNotificationsService._();
    }
    return _service;
  }

  PushNotificationsService._() {
    _firebase = FirebaseMessaging.instance;
  }

  static PushNotificationsService get instance => _service;

  void requestPermission() {
    if (Platform.isIOS) _firebase.requestPermission();
  }

  Stream<FirebaseNotification> get foregroundMessageStream {
    final transform =
        (RemoteMessage msg) => FirebaseNotification.fromJson(json: msg.data);

    return FirebaseMessaging.onMessage.map(transform);
  }
}
