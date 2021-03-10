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

class ChannelUpdateEvent extends NotificationEvent {
  final SocketChannelUpdateNotification data;

  ChannelUpdateEvent(this.data);

  @override
  List<Object> get props => [data];
}

class ChannelDeleteEvent extends NotificationEvent {
  final SocketChannelUpdateNotification data;

  ChannelDeleteEvent(this.data);

  @override
  List<Object> get props => [data];
}

class ReinitSubscriptions extends NotificationEvent {
  const ReinitSubscriptions();

  @override
  List<Object> get props => [];
}

class CancelPendingSubscriptions extends NotificationEvent {
  final String channelId;
  const CancelPendingSubscriptions(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class ChannelMessageEvent extends BaseChannelMessageEvent {
  const ChannelMessageEvent(MessageNotification data) : super(data);
}

class DirectMessageEvent extends BaseChannelMessageEvent {
  const DirectMessageEvent(MessageNotification data) : super(data);
}

class DirectMessageSocketEvent extends BaseChannelMessageEvent {
  const DirectMessageSocketEvent(SocketMessageUpdateNotification data)
      : super(data);
}

class ChannelMessageSocketEvent extends BaseChannelMessageEvent {
  const ChannelMessageSocketEvent(SocketMessageUpdateNotification data)
      : super(data);
}

class DirectThreadSocketEvent extends BaseChannelMessageEvent {
  const DirectThreadSocketEvent(SocketMessageUpdateNotification data)
      : super(data);
}

class ThreadMessageDeletedEvent extends BaseChannelMessageEvent {
  const ThreadMessageDeletedEvent(SocketMessageUpdateNotification data)
      : super(data);
}

class MessageDeletedEvent extends BaseChannelMessageEvent {
  const MessageDeletedEvent(SocketMessageUpdateNotification data) : super(data);
}

class ChannelThreadSocketEvent extends BaseChannelMessageEvent {
  const ChannelThreadSocketEvent(SocketMessageUpdateNotification data)
      : super(data);
}

// class UpdateDirectChannel extends BaseChannelMessageEvent {
// const UpdateDirectChannel(WhatsNewItem data) : super(data);
// }
//
// class UpdateClassicChannel extends BaseChannelMessageEvent {
// const UpdateClassicChannel(WhatsNewItem data) : super(data);
// }

class ThreadMessageEvent extends NotificationEvent {
  final MessageNotification data;

  const ThreadMessageEvent(this.data);

  @override
  List<Object> get props => [data];
}
