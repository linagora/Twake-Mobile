import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class TwakeSocket {
  IOWebSocketChannel _channel;
  final String _authJWToken;

  static const String _HOST = 'ws://purecode.ru:3124';
  TwakeSocket(this._authJWToken) {
    print('Connecting to web socket');
    _channel = IOWebSocketChannel.connect(_HOST);
    final token = "[]";
    print('TOKEN:\n$token');
    this.pushData(token);
  }

  String get token => _authJWToken;

  void pushData(String data) {
    if (_channel.closeCode != null) {
      throw Exception('Trying to send data over closed socket channel');
    }
    final token = "[]";
    print('TOKEN:\n$token');
    _channel.sink.add(token);
  }

  Stream<dynamic> get stream => _channel.stream;
  void close() {
    _channel.sink.close(status.goingAway);
  }
}

// TODO figure out how to make websockets work
