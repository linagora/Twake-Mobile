import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class NavigatorService {
  static late NavigatorService _service;
  final _pushNotifications = PushNotificationsService.instance;
  late final _navigatorKey;
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
  }

  static NavigatorService get instance => _service;

  Future<void> navigateOnNotificationLaunch() async {
    final local = await _pushNotifications.checkLocalNotificationClick;
    if (local != null) {
      final payload = NotificationPayload.fromJson(json: local.payload);
      // TODO navigate to required messages page
      return;
    }
    final remote = await _pushNotifications.checkRemoteNotificationClick;
    if (remote != null) {
      // TODO navigate to required messages page
    }
  }

  void listenToLocals() async {
    await for (final local in _pushNotifications.localNotifications) {}
  }

  void navigate({
    String? companyId,
    String? workspaceId,
    required String channelId,
    String? threadId,
  }) async {
    if (companyId == null) companyId = Globals.instance.companyId!;
    if (workspaceId == null) workspaceId = Globals.instance.workspaceId!;
    // TODO figure out the navigation
  }
}
