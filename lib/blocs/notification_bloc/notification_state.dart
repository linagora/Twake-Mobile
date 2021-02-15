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

class ChannelUpdated extends NotificationState {
  final SocketChannelUpdateNotification data;

  ChannelUpdated(this.data);

  @override
  List<Object> get props => [data];
}

class ChannelDeleted extends NotificationState {
  final SocketChannelUpdateNotification data;

  ChannelDeleted(this.data);

  @override
  List<Object> get props => [data];
}

class ThreadMessageDeleted extends NotificationState {
  final SocketMessageUpdateNotification data;
  ThreadMessageDeleted(this.data);

  @override
  List<Object> get props => [data];
}

class MessageDeleted extends NotificationState {
  final SocketMessageUpdateNotification data;
  MessageDeleted(this.data);

  @override
  List<Object> get props => [data];
}

class DirectThreadMessageArrived extends NotificationState {
  final SocketMessageUpdateNotification data;
  DirectThreadMessageArrived(this.data);

  @override
  List<Object> get props => [data];
}

class DirectMessageArrived extends NotificationState {
  final SocketMessageUpdateNotification data;
  DirectMessageArrived(this.data);

  @override
  List<Object> get props => [data];
}

class ChannelMessageArrived extends NotificationState {
  final SocketMessageUpdateNotification data;
  ChannelMessageArrived(this.data);

  @override
  List<Object> get props => [data];
}

class ChannelThreadMessageArrived extends NotificationState {
  final SocketMessageUpdateNotification data;
  ChannelThreadMessageArrived(this.data);

  @override
  List<Object> get props => [data];
}

class WorkspaceUpdated extends NotificationState {
  const WorkspaceUpdated();

  @override
  List<Object> get props => [];
}

// class DirectUpdateNotification extends NotificationState {
// final WhatsNewItem data;
//
// const DirectUpdateNotification(this.data);
//
// @override
// List<Object> get props => [data];
// }
//
// class ChannnelUpdateNotification extends NotificationState {
// final WhatsNewItem data;
//
// const ChannnelUpdateNotification(this.data);
//
// @override
// List<Object> get props => [data];
// }
//
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
