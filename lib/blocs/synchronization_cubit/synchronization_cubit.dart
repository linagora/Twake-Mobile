import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/socketio/socketio_room.dart';
import 'package:twake/services/service_bundle.dart';

class SynchronizationCubit extends Cubit {
  final _socketio = SocketIOService.instance;
  List<SocketIORoom> _subRooms = [];

  void subscribeToWorkspace({required String workspaceId}) {}

  void subscribeToChannel({required String channelId}) {
    if (Globals.instance.isNetworkConnected) _socketio.subscribe(room: room);
  }

  void unsubscribeFromChannel({required String channelId}) {
    if (Globals.instance.isNetworkConnected) _socketio.unsubscribe(room: room);
  }
}
