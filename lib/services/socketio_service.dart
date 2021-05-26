import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:twake/models/globals/globals.dart';

import 'service_bundle.dart';

class SocketIOService {
  static late SocketIOService _service;
  late final IO.Socket _socket;
  final _logger = Logger();
  Map<String, dynamic> _rooms = {};

  factory SocketIOService({required bool reset}) {
    if (reset) {
      _service = SocketIOService._();
    }
    return _service;
  }

  SocketIOService._() {
    final opts = IO.OptionBuilder()
        .setReconnectionDelay(3000) // wait 3 secs before reconnect
        .setPath('/socket')
        .enableAutoConnect()
        .enableReconnection()
        .setTransports(['websocket']).build();

    _socket = IO.io(Globals.instance.host, opts);

    // Set up all the event handlers
    _socket.onConnect((_) {
      _logger.v('Socket IO connection estabilished');

      _socket.emit(IOEvent.authenticate, {'token': Globals.instance.token});
    });

    _socket.on(IOEvent.authenticated, (_) {
      _logger.v('Successfully authenticated on Socket IO channel');
      _subscribe();
    });

    _socket.on(
      IOEvent.join_error,
      (e) => _logger.e('Error joining the room:\n$e'),
    );

    _socket.on(IOEvent.event, _handleEvent);

    _socket.on(IOEvent.resource, _handleResource);

    _socket.onError((e) => _logger.e('Error on Socket IO channel:\n$e'));

    _socket.onDisconnect((_) => _logger.w('Socket IO connection was aborted'));
  }

  static SocketIOService get instance => _service;

  void _subscribe() async {
    final queryParameters = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId
    };
    _rooms = await ApiService.instance.get(
      endpoint: Endpoint.notificationRooms,
      queryParameters: queryParameters,
    );

    for (final r in _rooms.keys) {
      _socket.emit(IOEvent.join, {'name': r, 'token': 'twake'});
    }
  }

  void _unsubscribe() {
    for (final r in _rooms.keys) {
      _socket.emit(IOEvent.leave, {'name': r, 'token': 'twake'});
    }
  }

  void _handleEvent(data) {
    // convert the data and emit new event to stream
  }

  void _handleResource(data) {
    // convert the data and emit new event to stream
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
