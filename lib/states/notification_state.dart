import 'package:equatable/equatable.dart';
import 'package:twake/models/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
}

class NotificationsAbsent extends NotificationState {
  const NotificationsAbsent();

  @override
  List<Object> get props => [];
}

abstract class BaseChannelMessageNotification extends NotificationState {
  final MessageNotification data;

  const BaseChannelMessageNotification(this.data);

  @override
  List<Object> get props => [data];
}

class ChannelMessageNotification extends BaseChannelMessageNotification {
  const ChannelMessageNotification(MessageNotification data) : super(data);
}

class DirectMessageNotification extends BaseChannelMessageNotification {
  const DirectMessageNotification(MessageNotification data) : super(data);
}

class ThreadMessageNotification extends BaseChannelMessageNotification {
  final MessageNotification data;

  const ThreadMessageNotification(this.data) : super(data);

  @override
  List<Object> get props => [data];
}
