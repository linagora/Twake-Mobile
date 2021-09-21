import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/socketio/socketio_event.dart';
import 'package:twake/models/socketio/socketio_resource.dart';

import 'service_bundle.dart';

export 'package:twake/models/socketio/socketio_event.dart';
export 'package:twake/models/socketio/socketio_resource.dart';

class SocketIOService {
  static late SocketIOService _service;
  late final IO.Socket _socket;

  bool _healthCheckRunning = false;

  StreamController<SocketIOResource> _resourceStream =
      StreamController.broadcast();

  StreamController<SocketIOEvent> _eventStream = StreamController.broadcast();
  StreamController<bool> _reconnectionStream = StreamController.broadcast();

  Stream<bool> get socketIOReconnectionStream => _reconnectionStream.stream;
  Stream<SocketIOEvent> get eventStream => _eventStream.stream;
  Stream<SocketIOResource> get resourceStream => _resourceStream.stream;

  factory SocketIOService({required bool reset}) {
    if (reset) {
      _service = SocketIOService._();
    }
    return _service;
  }

  SocketIOService._() {
    final opts = IO.OptionBuilder()
        .disableAutoConnect()
        .setReconnectionDelay(3000) // wait 3 secs before reconnect
        .setPath('/socket')
        .enableReconnection()
        .setTransports(['websocket']).build();

    _socket = IO.io(Globals.instance.host, opts);

    // Set up all the event handlers
    _socket.onConnect((_) {
      // Logger().v('Socket IO connection estabilished');

      _socket.emit(IOEvent.authenticate, {'token': Globals.instance.token});
    });

    _socket.on(IOEvent.authenticated, (_) {
      _reconnectionStream.sink.add(true);
      // Logger().v('Successfully authenticated on Socket IO channel');
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
      // (r) => {},
      (r) => Logger().v('successfully joined room $r'),
    );

    _socket.onError((e) => Logger().e('Error on Socket IO channel:\n$e'));

    _socket.onDisconnect((_) {
      _reconnectionStream.sink.add(false);
      // Logger().w('Socket IO connection was aborted');
    });

    _socket.connect();

    // set up health check for sockeio connection
    Future.delayed(Duration(seconds: 3), _startHealthCheck);

    Globals.instance.connection.listen((state) {
      if (state == Connection.connected && !_healthCheckRunning) {
        _startHealthCheck();
      } else {
        _healthCheckRunning = false;
      }
    });

    _socket.connect();
  }

  static SocketIOService get instance => _service;

  void subscribe({required String room}) async {
    _socket.emit(IOEvent.join, {'name': room, 'token': 'twake'});
  }

  void unsubscribe({required String room}) {
    _socket.emit(IOEvent.leave, {'name': room, 'token': 'twake'});
  }

  void _handleEvent(data) {
    // Logger().v('GOT EVENT: $data');
    final event = SocketIOEvent.fromJson(json: data);
    _eventStream.sink.add(event);
  }

  void _handleResource(data) {
    Logger().v('GOT RESOURCE: $data');
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
  }

  void disconnect() {
    _socket.disconnect();
  }

  void connect() {
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
