import 'package:equatable/equatable.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();
}

class ConnectionLost extends ConnectionState {
  final String force;
  const ConnectionLost(this.force);

  @override
  List<Object> get props => [force];
}

class ConnectionActive extends ConnectionState {
  const ConnectionActive();

  @override
  List<Object> get props => [];
}

class ConnectionWifi extends ConnectionActive {
  const ConnectionWifi();

  @override
  List<Object> get props => [];
}

class ConnectionCellular extends ConnectionActive {
  const ConnectionCellular();

  @override
  List<Object> get props => [];
}
