import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class SynchronizationService {
  static late SynchronizationService _service;

  SocketIOService _socketio = SocketIOService.instance;
  final _pushNotifications = PushNotificationsService.instance;

  String? subscribedChannelId;
  String? subscribedThreadId;

  String _currentPublicChannels = '';
  String _currentPrivateChannels = '';
  String _currentDirectChannels = '';

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
    _socketio = SocketIOService.instance; // reacquire new instance of socketio

    // Set up auto resubscription in case of internet connection loss
    _socketio.socketIOReconnectionStream.listen((authenticated) async {
      if (authenticated) {
        // wait for the socketio service to authenticate first
        Logger().v('Resubscribing on socketio reconnect');
        if (Globals.instance.companyId != null) {
          if (Globals.instance.workspaceId != null) {
            await subscribeForChannels(
                companyId: Globals.instance.companyId!,
                workspaceId: Globals.instance.workspaceId!);
          }
          await subscribeForChannels(
              companyId: Globals.instance.companyId!, workspaceId: 'direct');
        }

        await subscribeToBadges();

        if (subscribedChannelId != null && Globals.instance.companyId != null) {
          subscribeToMessages(channelId: subscribedChannelId!);
        }
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
        return r.type == ResourceType.channels &&
            r.resource['workspace_id'] == 'direct';
      });

  Stream<SocketIOResource> get socketIODirectMembershipStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.channelMember &&
            r.resource['workspace_id'] == 'direct';
      });

  Stream<SocketIOResource> get socketIOChannelMembershipStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.channelMember &&
            r.resource['workspace_id'] != 'direct';
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

  Stream<SocketIOResource> get socketIOChannelMessageStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.message &&
            r.resource['thread_id'] == r.resource['id'] &&
            r.resource['subtype'] != 'system' &&
            r.resource['subtype'] != 'application';
      });

  Stream<SocketIOResource> get socketIOThreadMessageStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.message &&
            r.resource['thread_id'] != r.resource['id'] &&
            r.resource['subtype'] != 'system' &&
            r.resource['subtype'] != 'application';
      });

  Stream<SocketIOResource> get sockeIOBadgesUpdateStream =>
      _socketio.resourceStream
          .where((r) => r.type == ResourceType.userNotificationBadges);

  Future<void> subscribeForChannels({
    required String workspaceId,
    required String companyId,
  }) async {
    if (Globals.instance.token == null) return;
    if (Globals.instance.companyId == null) return;
    if (Globals.instance.workspaceId == null) return;

    if (workspaceId != 'direct') {
      // Unsubscribe from previous workspace

      var t = sprintf(
        '/companies/%s/workspaces/%s/channels?type=public',
        [companyId, workspaceId],
      );
      if (t != _currentPublicChannels && _currentPublicChannels.isNotEmpty)
        _socketio.unsubscribe(room: _currentPublicChannels);
      _currentPublicChannels = t;

      t = sprintf(
        '/companies/%s/workspaces/%s/channels?type=private&user=%s',
        [companyId, workspaceId, Globals.instance.userId],
      );

      if (t != _currentPrivateChannels && _currentPrivateChannels.isNotEmpty)
        _socketio.unsubscribe(room: _currentPrivateChannels);

      _currentPrivateChannels = t;

      _socketio.subscribe(room: _currentPublicChannels);

      _socketio.subscribe(room: _currentPrivateChannels);
    } else {
      final t = sprintf(
        '/companies/%s/workspaces/direct/channels?type=direct&user=%s',
        [companyId, Globals.instance.userId],
      );
      if (t != _currentDirectChannels && _currentDirectChannels.isNotEmpty) {
        _socketio.unsubscribe(room: _currentDirectChannels);
      }
      _currentDirectChannels = t;
      _socketio.subscribe(room: _currentDirectChannels);
    }
  }

  Future<void> subscribeToBadges() async {
    if (Globals.instance.token == null) return;

    final room = sprintf(
      '/notifications?type=private&user=%s',
      [Globals.instance.userId],
    );

    _socketio.subscribe(room: room);
  }

  void subscribeToWriting() async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    final room = sprintf('/companies/%s/workspaces', [
      Globals.instance.companyId,
    ]);
    _socketio.subscribe(room: room);
  }

  void subscribeToOnlineStatus() async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    final room = sprintf('/users/online/%s', [
      Globals.instance.companyId,
    ]);
    final userRoom = sprintf('/users/%s', [
      Globals.instance.userId,
    ]);

    _socketio.subscribeToOnlineStatus(room: room, userRoom: userRoom);
  }

  void getOnlineStatus(List<String> users) async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    final room = sprintf('/users/online/%s', [
      Globals.instance.companyId,
    ]);
    final data = {'name': room, 'type': 'user:online', 'data': users};

    _socketio.emitEventOnlineStatus(data);
  }

  void setOnlineStatus() async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    final List<String> data = [Globals.instance.userId ?? ""];

    _socketio.setOnlineStatus(data);
  }

  void emitWritingEvent(WritingData writingData) async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    final room = sprintf('/companies/%s/workspaces', [
      Globals.instance.companyId,
    ]);

    final event = SocketIOWritingEvent(name: room, data: writingData).toJson();
    event["token"] = "twake";

    _socketio.emitEvent(event);
  }

  void unSubscribeFromWriting() async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    final room = sprintf('/companies/%s/workspaces', [
      Globals.instance.companyId,
    ]);
    // Subscribe, to new company
    _socketio.subscribe(room: room);
  }

  void subscribeToMessages({
    required String channelId,
    bool isDirect: false,
  }) async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Should not be called with no active connection');

    // Unsubscribe just in case
    if (subscribedChannelId != null)
      unsubscribeFromMessages(
        channelId: subscribedChannelId!,
        isDirect: isDirect,
      );

    final room = sprintf('/companies/%s/workspaces/%s/channels/%s/feed', [
      Globals.instance.companyId,
      isDirect ? 'direct' : Globals.instance.workspaceId,
      channelId,
    ]);
    // Subscribe, to new channel
    _socketio.subscribe(room: room);

    subscribedChannelId = channelId;
  }

  void subscribeToThreadReplies({required String threadId}) async {
    if (!Globals.instance.isNetworkConnected) return;

    // Unsubscribe just in case
    if (subscribedThreadId != null) {
      unsubscribeFromThreadReplies(threadId: subscribedThreadId!);
    }

    final room = sprintf('/companies/%s/threads/%s', [
      Globals.instance.companyId,
      threadId,
    ]);
    // Subscribe, to new channel
    _socketio.subscribe(room: room);

    subscribedThreadId = threadId;
  }

  void unsubscribeFromMessages({
    required String channelId,
    bool isDirect: false,
  }) {
    final room = sprintf('/companies/%s/workspaces/%s/channels/%s/feed', [
      Globals.instance.companyId,
      isDirect ? 'direct' : Globals.instance.workspaceId,
      channelId,
    ]);

    _socketio.unsubscribe(room: room);

    subscribedChannelId = null;
  }

  void unsubscribeFromThreadReplies({required String threadId}) {
    final room = sprintf('/companies/%s/threads/%s', [
      Globals.instance.companyId,
      subscribedThreadId,
    ]);
    _socketio.unsubscribe(room: room);

    subscribedThreadId = null;
  }
}
