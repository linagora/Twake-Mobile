import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class SynchronizationService {
  static late SynchronizationService _service;

  final _socketio = SocketIOService.instance;
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

    // Set up auto resubscription in case of internet connection loss
    _socketio.socketIOReconnectionStream.listen((authenticated) async {
      if (authenticated) {
        Logger().v('Resubscribing on socketio reconnect');
        // wait for the socketio service to authenticate first
        await Future.delayed(Duration(seconds: 3));
        await subscribeForChannels(
            companyId: Globals.instance.companyId!,
            workspaceId: Globals.instance.workspaceId!);
        await subscribeForChannels(
            companyId: Globals.instance.companyId!, workspaceId: 'direct');

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

  Stream<SocketIOResource> get socketIOChannelMessageStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.message &&
            r.resource['thread_id'] == r.resource['id'] &&
            r.resource['subtype'] == null;
      });

  Stream<SocketIOResource> get socketIOThreadMessageStream =>
      _socketio.resourceStream.where((r) {
        return r.type == ResourceType.message &&
            r.resource['thread_id'] != r.resource['id'] &&
            r.resource['subtype'] != 'deleted';
      });

  Stream<SocketIOResource> get sockeIOBadgesUpdateStream =>
      _socketio.resourceStream
          .where((r) => r.type == ResourceType.userNotificationBadges);

  Future<void> subscribeForChannels({
    required String workspaceId,
    required String companyId,
  }) async {
    if (Globals.instance.token == null) return;

    if (workspaceId != 'direct') {
      // Unsubscribe from previous workspace
      _socketio.unsubscribe(room: _currentPublicChannels);
      _socketio.unsubscribe(room: _currentPrivateChannels);

      _currentPublicChannels = sprintf(
        '/companies/%s/workspaces/%s/channels?type=public',
        [companyId, workspaceId],
      );
      _socketio.subscribe(room: _currentPublicChannels);

      _currentPrivateChannels = sprintf(
        '/companies/%s/workspaces/%s/channels?type=private&user=%s',
        [companyId, workspaceId, Globals.instance.userId],
      );
      _socketio.subscribe(room: _currentPrivateChannels);
    } else {
      _socketio.unsubscribe(room: _currentDirectChannels);

      _currentDirectChannels = sprintf(
        '/companies/%s/workspaces/direct/channels?type=direct&user=%s)',
        [companyId, Globals.instance.userId],
      );
      _socketio.subscribe(room: _currentDirectChannels);
    }
  }

  Future<void> subscribeToBadges() async {
    if (Globals.instance.token == null) return;

    final room = sprintf(
        '/notifications?type=private&user=%s', [Globals.instance.userId]);

    _socketio.subscribe(room: room);
  }

  void subscribeToMessages({required String channelId}) async {
    if (!Globals.instance.isNetworkConnected)
      throw Exception('Shoud not be called with no active connection');

    // Unsubscribe just in case
    if (subscribedChannelId != null)
      unsubscribeFromMessages(channelId: subscribedChannelId!);

    final room = sprintf('/companies/%s/workspaces/%s/channels/%s/feed', [
      Globals.instance.companyId,
      Globals.instance.workspaceId,
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

  void unsubscribeFromMessages({required String channelId}) {
    final room = sprintf('/companies/%s/workspaces/%s/channels/%s/feed', [
      Globals.instance.companyId,
      Globals.instance.workspaceId,
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
