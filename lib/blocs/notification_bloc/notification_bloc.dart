import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/connection_bloc/connection_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_event.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/services/notifications.dart';
import 'package:twake/blocs/notification_bloc/notification_state.dart';
import 'package:twake/models/notification.dart';
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
  String socketIOHost;
  final logger = Logger();
  final _api = Api();
  List<String> subscriptions = [];
  Map<String, dynamic> subscriptionRooms = {};
  StreamSubscription _subscription;

  NotificationBloc({
    this.token,
    this.socketIOHost,
    ConnectionBloc connectionBloc,
  }) : super(NotificationsAbsent()) {
    service = Notifications(
      onMessageCallback: onMessageCallback,
      onResumeCallback: onResumeCallback,
      onLaunchCallback: onLaunchCallback,
    );
    socket = IO.io(
      this.socketIOHost,
      IO.OptionBuilder()
          .setPath('/socket')
          .setTimeout(10000)
          .disableAutoConnect()
          .setTransports(['websocket']).build(),
    );
    _subscription = connectionBloc.listen((state) {
      if (state is ConnectionLost) {
        // socket = socket.close();
      } else if (state is ConnectionActive) {
        reinit();
      }
    });
    print('TOKEN: $token\nHOST: ${socket.opts}');
    setupListeners();
    socket = socket.connect();
  }

  void setupListeners() {
    socket.onReconnect((_) {
      logger.d('RECCONNECTED, RESETTING SUBSCRIPTIONS');
    });
    socket.onConnect((msg) {
      logger.d('CONNECTED ON SOCKET IO\n$token');
      socketConnectionState = SocketConnectionState.CONNECTED;
      socket.emit(SocketIOEvent.AUTHENTICATE, {'token': this.token});
    });
    socket.onError((e) => logger.e('ERROR ON SOCKET \n$e'));
    socket.onDisconnect((msg) {
      logger.e('DISCONNECTED FROM SOCKET\n$msg');
      socketConnectionState = SocketConnectionState.DISCONNECTED;
    });
    socket.on(SocketIOEvent.AUTHENTICATED, (data) async {
      logger.d('AUTHENTICATED ON SOCKET: $data');
      socketConnectionState = SocketConnectionState.AUTHENTICATED;
      await setSubscriptions();
    });
    // socket.onPing((ping) {
    // logger.d('PING $ping');
    // });
    socket.on(SocketIOEvent.EVENT, (data) {
      logger.d('GOT EVENT: $data');
      handleSocketEvent(data);
    });
    socket.on(SocketIOEvent.RESOURCE, (data) {
      // logger.d('GOT RESOURCE: $data');
      handleSocketRosource(data);
    });
    socket.on(SocketIOEvent.JOIN_ERROR, (data) {
      logger.d('FAILED TO JOIN: $data');
    });
    socket.on(SocketIOEvent.JOIN_SUCCESS, (data) {
      // logger.d('SUCCESSFUL JOIN: $data');
    });
  }

  void reinit() {
    for (String room in subscriptionRooms.keys) {
      unsubscribe(room);
    }
    setSubscriptions();
  }

  Future<void> setSubscriptions() async {
    subscriptionRooms = await _api.get(
      Endpoint.notificationRooms,
      params: {
        'company_id': ProfileBloc.selectedCompany,
        'workspace_id': ProfileBloc.selectedWorkspace,
      },
    );
    for (String room in subscriptionRooms.keys) {
      subscribe(room);
    }
  }

  void subscribe(String path, [String tag = 'twake']) {
    socket.emit(SocketIOEvent.JOIN, {'name': path, 'token': tag});
    // logger.d('SUBSCRIBED ON $path');
  }

  void unsubscribe(String path, [String tag = 'twake']) {
    socket.emit(SocketIOEvent.LEAVE, {'name': path, 'token': tag});
    logger.d('UNSUBSCRIBED FROM $path');
  }

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    if (event is DirectMessageEvent) {
      yield DirectMessageNotification(event.data);
    } else if (event is ChannelMessageEvent) {
      yield ChannelMessageNotification(event.data);
    } else if (event is ThreadMessageEvent) {
      yield ThreadMessageNotification(event.data);
    } else if (event is ChannelMessageSocketEvent) {
      yield ChannelMessageArrived(event.data);
    } else if (event is DirectMessageSocketEvent) {
      yield DirectMessageArrived(event.data);
    } else if (event is ChannelThreadSocketEvent) {
      yield ChannelThreadMessageArrived(event.data);
    } else if (event is DirectThreadSocketEvent) {
      yield DirectThreadMessageArrived(event.data);
    } else if (event is ThreadMessageDeletedEvent) {
      yield ThreadMessageDeleted(event.data);
    } else if (event is MessageDeletedEvent) {
      yield MessageDeleted(event.data);
    } else if (event is ChannelUpdateEvent) {
      yield ChannelUpdated(event.data);
    } else if (event is ChannelDeleteEvent) {
      yield ChannelDeleted(event.data);
    } else if (event is ReinitSubscriptions) {
      reinit();
    }
  }

  void onMessageCallback(NotificationData data) {
    // if (data is MessageNotification) {
    // if (data.threadId.isNotEmpty && data.threadId != data.messageId) {
    // this.add(ThreadMessageEvent(data));
    // } else if (data.workspaceId == null) {
    // this.add(DirectMessageEvent(data));
    // } else {
    // this.add(ChannelMessageEvent(data));
    // }
    // } else if (data is WhatsNewItem) {
    // if (data.workspaceId == null) {
    // this.add(UpdateDirectChannel(data));
    // } else {
    // this.add(UpdateClassicChannel(data));
    // }
    // }
  }

  void onResumeCallback(NotificationData data) {
    throw 'Have to implement navagation to the right page';
  }

  void onLaunchCallback(NotificationData data) {
    throw 'Have to implement navagation to the right page';
  }

  void handleSocketRosource(Map resource) {
    final type = getSocketResourceType(resource);
    logger.w('RESOURCE ID: $type');
    if (type == SocketResourceType.ChannelUpdate) {
      final data =
          SocketChannelUpdateNotification.fromJson(resource['resource']);
      this.add(ChannelUpdateEvent(data));
    } else if (type == SocketResourceType.ChannelDelete) {
      final data =
          SocketChannelUpdateNotification.fromJson(resource['resource']);
      this.add(ChannelDeleteEvent(data));
    }
  }

  void handleSocketEvent(Map event) {
    final type = getSocketEventType(event);
    final id = getRoomSubscriberId(event['name']);
    NotificationData data;
    event['data']['channel_id'] = id;
    data = SocketMessageUpdateNotification.fromJson(event['data']);
    switch (type) {
      case SocketEventType.Unknown:
        throw Exception('Got unknown event:\n$event');

      case SocketEventType.ChannelMessage:
        this.add(ChannelMessageSocketEvent(data));
        break;

      case SocketEventType.DirectMessage:
        this.add(DirectMessageSocketEvent(data));
        break;

      case SocketEventType.ChannelThreadMessage:
        this.add(ChannelThreadSocketEvent(data));
        break;

      case SocketEventType.DirectThreadMessage:
        this.add(DirectThreadSocketEvent(data));
        break;

      case SocketEventType.ThreadMessageDeleted:
        this.add(ThreadMessageDeletedEvent(data));
        break;

      case SocketEventType.MessageDeleted:
        this.add(MessageDeletedEvent(data));
        break;
    }
  }

  SocketEventType getSocketEventType(Map event) {
    if (!subscriptionRooms.containsKey(event['name']))
      return SocketEventType.Unknown;
    final type = subscriptionRooms[event['name']]['type'];
    if (event['data']['action'] == 'update') {
      if (type == 'CHANNEL') {
        if (event['data']['thread_id'] != null &&
            event['data']['thread_id'] != '') {
          return SocketEventType.ChannelThreadMessage;
        } else
          return SocketEventType.ChannelMessage;
      } else if (type == 'DIRECT') {
        if (event['data']['thread_id'] != null &&
            event['data']['thread_id'] != '') {
          return SocketEventType.DirectThreadMessage;
        } else {
          return SocketEventType.DirectMessage;
        }
      }
    } else if (event['data']['action'] == 'remove') {
      if (event['data']['thread_id'] != null &&
          event['data']['thread_id'] != '') {
        return SocketEventType.ThreadMessageDeleted;
      } else
        return SocketEventType.MessageDeleted;
    }
    return SocketEventType.Unknown;
  }

  SocketResourceType getSocketResourceType(Map resource) {
    if (!subscriptionRooms.containsKey(resource['room']))
      return SocketResourceType.Unknown;
    final type = subscriptionRooms[resource['room']]['type'];
    if (type == 'CHANNELS_LIST') {
      if (resource['type'] == 'channel') {
        if (resource['action'] == 'saved') {
          return SocketResourceType.ChannelUpdate;
        } else if (resource['action'] == 'deleted')
          return SocketResourceType.ChannelDelete;
      }
    }
    return SocketResourceType.Unknown;
  }

  String getRoomSubscriberId(String name) {
    if (!subscriptionRooms.containsKey(name)) return null;
    return subscriptionRooms[name]['id'];
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
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

enum SocketEventType {
  ChannelMessage,
  ChannelThreadMessage,
  DirectMessage,
  DirectThreadMessage,
  MessageDeleted,
  ThreadMessageDeleted,
  Unknown,
}

enum SocketResourceType {
  ChannelUpdate,
  ChannelDelete,
  DirectUpdate,
  Unknown,
}
