import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_notification.g.dart';

class FirebaseMessage {
  final NotificationPayload payload;
  final NotificationHeaders headers;

  const FirebaseMessage({
    required this.payload,
    required this.headers,
  });

  FirebaseMessage.fromRemote({required RemoteMessage remoteMessage})
      : payload = NotificationPayload.fromJson(
            json: jsonDecode(remoteMessage.data['notification_data'])),
        headers = NotificationHeaders.fromNotification(
          remote: remoteMessage.notification!,
        );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationPayload {
  final String companyId;

  final String workspaceId;

  final String channelId;

  final String? threadId;

  final String messageId;

  const NotificationPayload({
    required this.companyId,
    required this.workspaceId,
    required this.channelId,
    required this.messageId,
    this.threadId,
  });

  factory NotificationPayload.fromJson({required Map<String, dynamic> json}) {
    return _$NotificationPayloadFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$NotificationPayloadToJson(this);
  }

  String get stringified => jsonEncode(this.toJson());
}

class NotificationHeaders {
  final String title;
  final String body;

  const NotificationHeaders({
    required this.title,
    required this.body,
  });

  NotificationHeaders.fromNotification({required RemoteNotification remote})
      : title = remote.title!,
        body = remote.body!;
}
