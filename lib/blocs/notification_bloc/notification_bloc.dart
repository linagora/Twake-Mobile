import 'dart:async';
import 'dart:convert' show jsonEncode;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_event.dart';
import 'package:twake/services/notifications.dart';
import 'package:twake/blocs/notification_bloc/notification_state.dart';
import 'package:twake/models/notification.dart';
// import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:twake/services/service_bundle.dart';

export 'package:twake/blocs/notification_bloc/notification_event.dart';
export 'package:twake/blocs/notification_bloc/notification_state.dart';
export 'package:twake/models/notification.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  Notifications service;
  IO.Socket socket;
  var socketConnectionState = SocketConnectionState.DISCONNECTED;
  String token;
  final logger = Logger();
  List<String> subscriptions = [];

  NotificationBloc(this.token) : super(NotificationsAbsent()) {
    service = Notifications(
      onMessageCallback: onMessageCallback,
      onResumeCallback: onResumeCallback,
      onLaunchCallback: onLaunchCallback,
    );
    socket = IO.io(
      'https://web.qa.twake.app',
      IO.OptionBuilder()
          .setPath('/socket')
          .setTimeout(10000)
          .disableAutoConnect()
          .setTransports(['websocket']).build(),
    );
    socket.onConnect((msg) {
      logger.d('CONNECTED ON SOCKET IO');
      socketConnectionState = SocketConnectionState.CONNECTED;
      socket.emit(SocketIOEvent.AUTHENTICATE, {'token': this.token});
    });
    socket.onError((e) => logger.e('ERROR ON SOCKET \n$e'));
    socket.onDisconnect((msg) {
      logger.e('DISCONNECTED FROM SOCKET\n$msg');
      socketConnectionState = SocketConnectionState.DISCONNECTED;
    });
    socket.on(SocketIOEvent.AUTHENTICATED, (data) {
      logger.d('AUTHENTICATED ON SOCKET: $data');
      socketConnectionState = SocketConnectionState.AUTHENTICATED;
    });

    socket.on(SocketIOEvent.EVENT, (data) {
      logger.d('GOT EVENT: $data');
    });
    socket.on(SocketIOEvent.RESOURCE, (data) {
      logger.d('GOT RESOURCE: $data');
    });
    socket.on(SocketIOEvent.JOIN_ERROR, (data) {
      logger.d('FAILED TO JOIN: $data');
    });
    socket.on(SocketIOEvent.JOIN_SUCCESS, (data) {
      logger.d('SUCCESSFUL JOIN: $data');
    });
    socket = socket.connect();
  }

  void subscribe(String path, [String tag = 'twake']) {
    socket.emit(SocketIOEvent.JOIN, {'name': path, 'tag': tag});
    logger.d('SUBSCRIBED ON $path');
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

class SocketIOEvent {
  static const AUTHENTICATE = 'authenticate';
  static const AUTHENTICATED = 'authenticated';
  static const JOIN_SUCCESS = 'realtime:join:success';
  static const JOIN_ERROR = 'realtime:join:error';
  static const RESOURCE = 'realtime:resource';
  static const EVENT = 'realtime:event';
  static const JOIN = 'realtime:join';
  static const LEAVE = 'realtime:leave';
}

enum SocketConnectionState {
  CONNECTED,
  AUTHENTICATED,
  DISCONNECTED,
}
