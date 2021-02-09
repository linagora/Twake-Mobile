import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_event.dart';
import 'package:twake/services/notifications.dart';
import 'package:twake/blocs/notification_bloc/notification_state.dart';
import 'package:twake/models/notification.dart';
// import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

export 'package:twake/blocs/notification_bloc/notification_event.dart';
export 'package:twake/blocs/notification_bloc/notification_state.dart';
export 'package:twake/models/notification.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  Notifications service;
  IO.Socket socket;
  NotificationBloc() : super(NotificationsAbsent()) {
    service = Notifications(
      onMessageCallback: onMessageCallback,
      onResumeCallback: onResumeCallback,
      onLaunchCallback: onLaunchCallback,
    );
    socket = IO.io(
      'https://mobile.api.twake.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.onConnect((_) {
      print('CONNECT');
      socket.emit('msg', 'test');
    });
    socket.onError((e) => print('ERROR ON CONNECT $e'));
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    // print('DONE SOCKETING');
    socket.connect();
  }

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    if (event is DirectMessageEvent) {
      yield DirectMessageNotification(event.data);
    } else if (event is ChannelMessageEvent) {
      yield ChannelMessageNotification(event.data);
    } else if (event is ThreadMessageEvent) {
      yield ThreadMessageNotification(event.data);
    } else if (event is UpdateDirectChannel) {
      yield DirectMessageNotification(event.data);
    } else if (event is UpdateClassicChannel) {
      yield ChannelMessageNotification(event.data);
    }
  }

  void onMessageCallback(NotificationData data) {
    if (data is MessageNotification) {
      // TODO remove monkey patch
      // if (data.channelId[14] == '1') {
      // data.channelId = data.channelId.replaceRange(14, 15, '4');
      // }
      if (data.threadId.isNotEmpty) {
        this.add(ThreadMessageEvent(data));
      } else if (data.workspaceId == null) {
        this.add(DirectMessageEvent(data));
      } else {
        this.add(ChannelMessageEvent(data));
      }
    } else if (data is WhatsNewItem) {
      if (data.workspaceId == null) {
        this.add(UpdateDirectChannel(data));
      } else {
        this.add(UpdateClassicChannel(data));
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
