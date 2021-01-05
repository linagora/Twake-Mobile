import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/notification_event.dart';
import 'package:twake/services/notifications.dart';
import 'package:twake/states/notification_state.dart';
import 'package:twake/models/notification.dart';

export 'package:twake/events/notification_event.dart';
export 'package:twake/states/notification_state.dart';
export 'package:twake/models/notification.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  Notifications service;

  NotificationBloc() : super(NotificationsAbsent()) {
    service = Notifications(
      onMessageCallback: onMessageCallback,
      onResumeCallback: onResumeCallback,
      onLaunchCallback: onLaunchCallback,
    );
  }

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    if (event is DirectMessageEvent) {
      yield DirectMessageNotification(event.data);
    } else if (event is ChannelMessageEvent) {
      yield ChannelMessageNotification(event.data);
    } else if (event is ThreadMessageEvent) {
      yield ThreadMessageNotification(event.data);
    }
  }

  void onMessageCallback(NotificationData data) {
    if (data is MessageNotification) {
      // TODO remove monkey patch
      if (data.channelId[14] == '1') {
        data.channelId = data.channelId.replaceRange(14, 15, '4');
      }
      if (data.threadId.isNotEmpty) {
        this.add(ThreadMessageEvent(data));
      } else if (data.workspaceId == null) {
        this.add(DirectMessageEvent(data));
      } else {
        this.add(ChannelMessageEvent(data));
      }
    }
  }

  void onResumeCallback(NotificationData data) {
    throw 'Have to implement navagation to the right page';
  }

  void onLaunchCallback(NotificationData data) {
    throw 'Have to implement navagation to the right page';
  }
}
