import 'package:equatable/equatable.dart';
import 'package:twake/models/notification.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class ChannelMessageEvent extends NotificationEvent {
  final MessageNotification data;
  const ChannelMessageEvent(this.data);

  @override
  List<Object> get props => [data];
}

class ThreadMessageEvent extends NotificationEvent {
  final MessageNotification data;
  const ThreadMessageEvent(this.data);

  @override
  List<Object> get props => [data];
}
