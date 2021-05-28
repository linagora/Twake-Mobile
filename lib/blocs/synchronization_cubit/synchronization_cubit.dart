import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/socketio/socketio_room.dart';
import 'package:twake/services/service_bundle.dart';

class Synchronization {
  static Synchronization? _synchronization;
  final _api = ApiService.instance;

  // Singleton pattern
  factory Synchronization() {
    if (_synchronization == null) {
      _synchronization = Synchronization._();
    }
    return _synchronization!;
  }

  Synchronization._();

  final _socketio = SocketIOService.instance;
  List<SocketIORoom> _subRooms = [];

  Future<List<SocketIORoom>> get sockeIORooms async {
    final queryParameters = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId
    };
    final List<Map<String, dynamic>> result = await _api.get(
      endpoint: Endpoint.notificationRooms,
      queryParameters: queryParameters,
    );

    final rooms = result.map((r) => SocketIORoom.fromJson(json: r));

    return rooms.toList();
  }

  Future<Stream<SocketIOResource>> subscribeForChannels() async {
    const wsRooms = const [RoomType.channelsList, RoomType.directsList];

    // unsubscribe from previous workspace
    for (final room in _subRooms.where((r) => wsRooms.contains(r.type))) {
      _socketio.subscribe(room: room.key);
    }
    // request rooms for new workspace
    _subRooms = await sockeIORooms;

    // subscribe for new workspace
    for (final room in _subRooms.where((r) => wsRooms.contains(r.type))) {
      _socketio.subscribe(room: room.key);
    }

    return _socketio.resourceStream;
  }

  // TODO: implement subscription to badge updates

  Stream<SocketIOEvent> subscribeToMessages({required String channelId}) {
    // TODO merge with unsubscribe method via subscribe field in SocketIORoom
    if (Globals.instance.isNetworkConnected)
      throw Exception('Shoud not be called with no active connection');

    // Make sure that channel rooms has been fetched before
    final channelRoom = _subRooms
        .firstWhere((r) => r.type == RoomType.channel && r.id == channelId);

    _socketio.subscribe(room: channelRoom.key);

    return _socketio.eventStream;
  }

  void unsubscribeFromMessages({required String channelId}) {
    if (Globals.instance.isNetworkConnected) return;

    final channelRoom = _subRooms
        .firstWhere((r) => r.type == RoomType.channel && r.id == channelId);

    _socketio.unsubscribe(room: channelRoom.key);
  }
}
