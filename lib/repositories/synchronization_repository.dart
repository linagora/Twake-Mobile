/* import 'package:twake/services/service_bundle.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/socketio/socketio_room.dart';

class SynchronizationRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;
  final _notifications = PushNotificationsService.instance;
  final _socketio = SocketIOService.instance;
  List<SocketIORoom> _rooms = [];

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
}
 */
