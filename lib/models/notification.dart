import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

abstract class NotificationData extends Equatable {
  const NotificationData();
}

@JsonSerializable()
class MessageNotification extends NotificationData {
  @JsonKey(name: 'company_id')
  final String companyId;
  @JsonKey(name: 'workspace_id')
  final String workspaceId;
  @JsonKey(name: 'channel_id')
  final String channelId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'message_id')
  final String messageId;

  MessageNotification({
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
    this.messageId,
  });

  @override
  List<Object> get props => [messageId];

  factory MessageNotification.fromJson(Map<String, dynamic> json) =>
      _$MessageNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$MessageNotificationToJson(this);
}
