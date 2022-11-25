import 'dart:async';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:twake/models/globals/globals.dart';
import 'service_bundle.dart';
export 'package:twake/models/socketio/socketio_event.dart';
export 'package:twake/models/socketio/socketio_resource.dart';

class SocketIOService {
  static late SocketIOService _service;
  late IO.Socket _socket;

  bool _healthCheckRunning = false;

  StreamController<SocketIOResource> _resourceStream =
      StreamController.broadcast();
  StreamController<SocketIOEvent> _eventStream = StreamController.broadcast();
  StreamController<bool> _reconnectionStream = StreamController.broadcast();
  StreamController<SocketIOWritingEvent> _writingEventStream =
      StreamController.broadcast();
  StreamController<List<dynamic>> _onlineUserStream =
      StreamController.broadcast();

  Stream<List<dynamic>> get onlineUserStream => _onlineUserStream.stream;
  Stream<bool> get socketIOReconnectionStream => _reconnectionStream.stream;
  Stream<SocketIOEvent> get eventStream => _eventStream.stream;
  Stream<SocketIOWritingEvent> get writingEventStream =>
      _writingEventStream.stream;
  Stream<SocketIOResource> get resourceStream => _resourceStream.stream;

  factory SocketIOService({required bool reset}) {
    if (reset) {
      _service = SocketIOService._();
    }
    return _service;
  }

  void updateHost() {
    _socket.io.uri = Globals.instance.host;
    _socket.disconnect();
    _socket.connect();
  }

  SocketIOService._() {
    final opts = IO.OptionBuilder()
        .setReconnectionDelay(3000) // wait 3 secs before reconnect
        .setPath('/socket')
        .enableReconnection()
        .setTransports(['websocket']).build();

    _socket = IO.io(Globals.instance.host, opts);

    // Set up all the event handlers
    _socket.onConnect((_) {
      // Logger().v('Socket IO connection estabilished');

      // Logger().v('Trying to authenticate:\n${Globals.instance.token}');
      _socket.emit(IOEvent.authenticate, {'token': Globals.instance.token});
    });

    _socket.on(IOEvent.authenticated, (_) {
      _reconnectionStream.sink.add(true);
      // Logger().v('Successfully authenticated on Socket IO channel');

      // set up health check for sockeio connection
      Future.delayed(Duration(seconds: 3), _startHealthCheck);
    });

    _socket.on(
      IOEvent.leave,
      (r) => Logger().e('Left socketio room: $r'),
    );
    _socket.on(
      IOEvent.join_error,
      (e) => Logger().e('Error joining the room:\n$e'),
    );

    _socket.on(IOEvent.event, _handleEvent);

    _socket.on(IOEvent.resource, _handleResource);

    _socket.on(
      IOEvent.join_success,
      (r) => {},
      // (r) => Logger().v('successfully joined room $r'),
    );

    _socket.onError((e) => Logger().e('Error on Socket IO channel:\n$e'));

    _socket.onDisconnect((_) {
      _reconnectionStream.sink.add(false);
      // Logger().w('Socket IO connection was aborted');
    });

    Globals.instance.connection.listen((state) {
      if (state == Connection.connected) {
        _startHealthCheck();
      } else {
        _healthCheckRunning = false;
      }
    });
  }

  static SocketIOService get instance => _service;

  void subscribe({required String room}) async {
    _socket.emit(IOEvent.join, {'name': room, 'token': 'twake'});
  }

  void subscribeToOnlineStatus(
      {required String room, required String userRoom}) async {
    _socket.emit(IOEvent.join, {'name': room, 'token': Globals.instance.token});
    //  _socket.emit(
    //      IOEvent.join, {'name': userRoom, 'token': Globals.instance.token});
  }

  void emitEvent(dynamic data) async {
    _socket.emit(IOEvent.event, data);
  }

  /*void emitTestEvent() async {
    final WritingEvent writingEvent = WritingEvent(
        channelId: 'cd2576b7-9f33-4a43-831f-6dd96b5d5cc3',
        isWriting: true,
        name: 'Evgenii Sharanov',
        threadId: '',
        userId: 'e80375ba-ad99-11eb-b6c4-0242ac120003');

    final data = {
      'name': '/companies/56393af2-e5fe-11e9-b894-0242ac120004/workspaces',
      'data': {'type': 'writing', 'event': writingEvent},
      'token': 'twake'
    };

    _socket.emit("realtime:event", data);
  }*/

  void emitEventOnlineStatus(Map<String, dynamic> data) async {
    _socket.emitWithAck('online:get', data, ack: (data) {
      if (data != null) {
        if ((data as Map<String, dynamic>).containsKey('data')) {
          (data['data'] as List<dynamic>).forEach((element) {
            _onlineUserStream.add(element);
          });
        }
      }
    });
  }

  void setOnlineStatus(List<String> data) async {
    _socket.emit('online:set', data);
  }

  void unsubscribe({required String room}) {
    _socket.emit(IOEvent.leave, {'name': room, 'token': 'twake'});
  }

  void _handleEvent(data) {
    // Logger().v('GOT EVENT: $data');
    if (data['data'].containsKey('type')) {
      _writingEventStream.sink.add(SocketIOWritingEvent.fromJson(json: data));
    } else {
      _eventStream.sink.add(SocketIOEvent.fromJson(json: data));
    }
  }

  void _handleResource(data) {
    // Logger().v('GOT RESOURCE: $data');
    final resource = SocketIOResource.fromJson(json: data);
    _resourceStream.sink.add(resource);
  }

  void _startHealthCheck() {
    if (_healthCheckRunning) return;

    final glob = Globals.instance;
    if (!glob.isNetworkConnected || glob.token == null) {
      _healthCheckRunning = false;
      return;
    }

    _healthCheckRunning = true;
    _checkConnectionHealth();
  }

  void _checkConnectionHealth() async {
    if (!_socket.connected) {
      _socket.connect();
    }
    // wait for 5 sec and rerun the check and rerun
    Future.delayed(Duration(seconds: 30)).then((_) {
      _checkConnectionHealth();
    });
  }

  Future<void> dispose() async {
    await _eventStream.close();
    await _resourceStream.close();
    await _reconnectionStream.close();
    await _writingEventStream.close();
    await _onlineUserStream.close();
  }

  void disconnect() {
    _socket.disconnect();
  }

  void connect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
    _socket.connect();
  }
}

class IOEvent {
  static const authenticate = 'authenticate';
  static const authenticated = 'authenticated';
  static const join_success = 'realtime:join:success';
  static const join_error = 'realtime:join:error';
  static const resource = 'realtime:resource';
  static const event = 'realtime:event';
  static const join = 'realtime:join';
  static const leave = 'realtime:leave';
}
