import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/services/service_bundle.dart';

class NavigatorService {
  static late NavigatorService _service;
  final _pushNotifications = PushNotificationsService.instance;
  late final GlobalKey<NavigatorState> _navigatorKey;
  final CompaniesCubit companiesCubit;
  final WorkspacesCubit workspacesCubit;
  final ChannelsCubit channelsCubit;
  final DirectsCubit directsCubit;
  final ChannelMessagesCubit channelMessagesCubit;
  final ThreadMessagesCubit threadMessagesCubit;

  factory NavigatorService({
    required CompaniesCubit companiesCubit,
    required WorkspacesCubit workspacesCubit,
    required ChannelsCubit channelsCubit,
    required DirectsCubit directsCubit,
    required ChannelMessagesCubit channelMessagesCubit,
    required ThreadMessagesCubit threadMessagesCubit,
  }) {
    _service = NavigatorService._(
      companiesCubit: companiesCubit,
      workspacesCubit: workspacesCubit,
      channelsCubit: channelsCubit,
      directsCubit: directsCubit,
      channelMessagesCubit: channelMessagesCubit,
      threadMessagesCubit: threadMessagesCubit,
    );
    return _service;
  }

  NavigatorService._({
    required this.companiesCubit,
    required this.workspacesCubit,
    required this.channelsCubit,
    required this.directsCubit,
    required this.channelMessagesCubit,
    required this.threadMessagesCubit,
  }) {
    _navigatorKey = GlobalKey<NavigatorState>();

    // Run the notification click listeners
    listenToLocals();
    listenToRemote();
  }

  static NavigatorService get instance => _service;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Future<void> navigateOnNotificationLaunch() async {
    final local = await _pushNotifications.checkLocalNotificationClick;
    if (local != null) {
      final data = NotificationPayload.fromJson(json: local.payload);
      navigate(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId,
      );
      return;
    }
    final remote = await _pushNotifications.checkRemoteNotificationClick;
    if (remote != null) {
      final data = remote.payload;
      navigate(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId,
      );
    }
  }

  void listenToLocals() async {
    await for (final local in _pushNotifications.localNotifications) {
      if (local.type != LocalNotificationType.message) continue;
      final data = NotificationPayload.fromJson(json: local.payload);
      navigate(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId,
      );
    }
  }

  void listenToRemote() async {
    await for (final remote in _pushNotifications.notificationClickStream) {
      final data = remote.payload;
      navigate(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId,
      );
    }
  }

  Future<void> navigate({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
  }) async {
    if (companyId != null) {
      companiesCubit.selectCompany(companyId: companyId);
      await workspacesCubit.fetch(companyId: companyId);
      await directsCubit.fetch(companyId: companyId, workspaceId: 'direct');
      SynchronizationService.instance.subscribeToBadges();
    }
    if (workspaceId != null) {
      workspacesCubit.selectWorkspace(workspaceId: workspaceId);
      companiesCubit.selectWorkpsace(workspaceId: workspaceId);

      await channelsCubit.fetch(workspaceId: workspaceId);
    }

    channelsCubit.selectChannel(channelId: channelId);

    await channelMessagesCubit.fetch(channelId: channelId);

    if (threadId != null) {
      channelMessagesCubit.selectThread(messageId: threadId);
      await threadMessagesCubit.fetch(channelId: channelId, threadId: threadId);
    }

    // TODO: implement navigation
    // _navigatorKey.currentState.push();
  }
}
