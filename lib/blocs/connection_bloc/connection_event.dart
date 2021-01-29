import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
}

class NotifyConnectionWiFi extends ConnectionEvent {
  const NotifyConnectionWiFi();

  @override
  List<Object> get props => [];
}

class NotifyConnectionCellular extends ConnectionEvent {
  const NotifyConnectionCellular();

  @override
  List<Object> get props => [];
}

class NotifyConnectionLost extends ConnectionEvent {
  const NotifyConnectionLost();

  @override
  List<Object> get props => [];
}

class CheckConnectionState extends ConnectionEvent {
  const CheckConnectionState();

  @override
  List<Object> get props => [];
}
