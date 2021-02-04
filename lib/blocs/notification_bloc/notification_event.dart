import 'package:equatable/equatable.dart';
import 'package:twake/models/notification.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class BaseChannelMessageEvent extends NotificationEvent {
  final NotificationData data;

  const BaseChannelMessageEvent(this.data);

  @override
  List<Object> get props => [data];
}

class ChannelMessageEvent extends BaseChannelMessageEvent {
  const ChannelMessageEvent(MessageNotification data) : super(data);
}

class DirectMessageEvent extends BaseChannelMessageEvent {
  const DirectMessageEvent(MessageNotification data) : super(data);
}

class UpdateDirectChannel extends BaseChannelMessageEvent {
  const UpdateDirectChannel(MessageNotification data) : super(data);
}

class ThreadMessageEvent extends NotificationEvent {
  final MessageNotification data;

  const ThreadMessageEvent(this.data);

  @override
  List<Object> get props => [data];
}
