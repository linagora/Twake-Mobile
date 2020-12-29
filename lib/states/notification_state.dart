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

class ChannelMessageNotification extends NotificationState {
  final MessageNotification data;

  const ChannelMessageNotification(this.data);

  @override
  List<Object> get props => [data];
}

class ThreadMessageNotification extends NotificationState {
  final MessageNotification data;

  const ThreadMessageNotification(this.data);

  @override
  List<Object> get props => [data];
}
