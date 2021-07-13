import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/socketio/socketio_room.dart';
import 'package:twake/services/service_bundle.dart';

class SynchronizationService {
  static late SynchronizationService _service;
  final _api = ApiService.instance;

  final _socketio = SocketIOService.instance;
  final _pushNotifications = PushNotificationsService.instance;

  String? subscribedChannelId;

  List<SocketIORoom> _subRooms = [];
  Map<String, List<int>> _localNotifications = {};

  factory SynchronizationService({required bool reset}) {
    if (reset) {
      _service = SynchronizationService._();
    }
    return _service;
  }

  static SynchronizationService get instance => _service;

  SynchronizationService._() {
    foregroundMessagesCheck();

    // Set up auto resubscription in case of internet connection loss
    _socketio.socketIOReconnectionStream.listen((authenticated) async {
      if (authenticated && _subRooms.isNotEmpty) {
        Logger().v('Resubscribing on socketio reconnect');
        // wait for the socketio service to authenticate first
        await Future.delayed(Duration(seconds: 3));
        await subscribeForChannels();
        await subscribeToBadges();

        if (subscribedChannelId != null)
          subscribeToMessages(channelId: subscribedChannelId!);
      }
    });
  }

  Future<void> foregroundMessagesCheck() async {
    final messagesStream = _pushNotifications.foregroundMessageStream;
    await for (final message in messagesStream) {
      // Don't show notifications in channels, that are already being viewed
      if (message.payload.channelId == Globals.instance.channelId) continue;
      if (message.payload.threadId == Globals.instance.threadId) continue;

      final id = _pushNotifications.showLocal(
        title: message.headers.title,
        body: message.headers.body,
        payload: LocalNotification(
          type: LocalNotificationType.message,
          payload: message.payload.toJson(),
        ).stringified,
      );
      final notifications = _localNotifications.putIfAbsent(
        message.payload.channelId,
        () => [],
      );
      notifications.add(id);
    }
  }

  void cancelNotificationsForChannel({required String channelId}) {
    final notifications = _localNotifications[channelId];

    if (notifications == null || notifications.isEmpty) return;

    for (final n in notifications) {
      _pushNotifications.cancelLocal(id: n);
    }
  }

  Stream<SocketIOResource> get socketIODirectsStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.channel &&
            r.resource['workspace_id'] == 'direct';
      });

  Stream<SocketIOResource> get socketIODirectsActivityStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.channelActivity &&
            r.resource['workspace_id'] == 'direct';
      });

  Stream<SocketIOResource> get socketIOChannelsStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.channel &&
            r.resource['workspace_id'] != 'direct';
      });

  Stream<SocketIOResource> get socketIOChannelsActivityStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.channelActivity &&
            r.resource['workspace_id'] != 'direct';
      });

  Stream<SocketIOEvent> get socketIOChannelMessageStream =>
      _socketio.eventStream.where((e) {
        return (e.data.threadId?.isEmpty ?? true) ||
            e.data.threadId == e.data.messageId;
      });

  Stream<SocketIOEvent> get socketIOThreadMessageStream =>
      _socketio.eventStream.where((e) {
        return (e.data.threadId?.isNotEmpty ?? false) &&
            e.data.threadId != e.data.messageId;
      });

  Stream<SocketIOResource> get sockeIOBadgesUpdateStream =>
      _socketio.resourceStream
          .where((r) => r.type == ResourceType.userNotificationBadges);

  Future<List<SocketIORoom>> get socketIORooms async {
    final queryParameters = {
      'company_id': Globals.instance.companyId,
      'workspace_id': Globals.instance.workspaceId
    };
    final List<dynamic> result = await _api.get(
      endpoint: Endpoint.notificationRooms,
      queryParameters: queryParameters,
    );

    final rooms = result.map((r) => SocketIORoom.fromJson(json: r));

    return rooms.toList();
  }

  Future<void> refreshRooms() async {
    _subRooms = await socketIORooms;
  }

  Future<void> subscribeForChannels() async {
    if (Globals.instance.token == null) return;

    const wsRooms = const [RoomType.channelsList, RoomType.directsList];

    // Unsubscribe from previous workspace
    for (final room in _subRooms.where((r) => wsRooms.contains(r.type))) {
      _socketio.unsubscribe(room: room.key);
    }
    // Request rooms for new workspace
    await refreshRooms();

    // Subscribe for new workspace
    for (final room in _subRooms.where((r) => wsRooms.contains(r.type))) {
      _socketio.subscribe(room: room.key);
    }
  }

  Future<void> subscribeToBadges() async {
    if (Globals.instance.token == null) return;

    if (!_subRooms.any((r) => r.type == RoomType.notifications)) {
      await refreshRooms();
    }

    final badgesRoom =
        _subRooms.firstWhere((r) => r.type == RoomType.notifications);

    _socketio.subscribe(room: badgesRoom.key);
  }

  void subscribeToMessages({required String channelId}) async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Shoud not be called with no active connection');

    // Unsubscribe just in case
    unsubscribeFromMessages(channelId: channelId);

    // if the channel is not present, rerequest the list
    if (!_subRooms.any((r) =>
        const [RoomType.channel, RoomType.direct].contains(r.type) &&
        r.id == channelId)) await refreshRooms();

    // Make sure that channel rooms has been fetched before,
    // or you'll get Bad state
    final channelRoom = _subRooms.firstWhere((r) =>
        const [RoomType.channel, RoomType.direct].contains(r.type) &&
        r.id == channelId);

    // Subscribe, to new channel
    _socketio.subscribe(room: channelRoom.key);
    channelRoom.subscribed = true;

    subscribedChannelId = channelId;
  }

  void unsubscribeFromMessages({required String channelId}) {
    if (!_subRooms.any((r) => r.id == channelId)) return;

    final room = _subRooms.firstWhere((r) => r.id == channelId);

    _socketio.unsubscribe(room: room.key);
    room.subscribed = false;

    subscribedChannelId = null;
  }
}
