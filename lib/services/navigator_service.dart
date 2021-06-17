import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/pages/twake_web_view.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/service_bundle.dart';

class NavigatorService {
  static late NavigatorService _service;
  final _pushNotifications = PushNotificationsService.instance;
  final AccountCubit accountCubit;
  final CompaniesCubit companiesCubit;
  final WorkspacesCubit workspacesCubit;
  final ChannelsCubit channelsCubit;
  final DirectsCubit directsCubit;
  final ChannelMessagesCubit channelMessagesCubit;
  final ThreadMessagesCubit threadMessagesCubit;

  factory NavigatorService({
    required AccountCubit accountCubit,
    required CompaniesCubit companiesCubit,
    required WorkspacesCubit workspacesCubit,
    required ChannelsCubit channelsCubit,
    required DirectsCubit directsCubit,
    required ChannelMessagesCubit channelMessagesCubit,
    required ThreadMessagesCubit threadMessagesCubit,
  }) {
    _service = NavigatorService._(
      accountCubit: accountCubit,
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
    required this.accountCubit,
    required this.companiesCubit,
    required this.workspacesCubit,
    required this.channelsCubit,
    required this.directsCubit,
    required this.channelMessagesCubit,
    required this.threadMessagesCubit,
  }) {
    // Run the notification click listeners
    listenToLocals();
    listenToRemote();
  }

  static NavigatorService get instance => _service;

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
    }
    if (workspaceId != null && workspaceId != 'direct') {
      workspacesCubit.selectWorkspace(workspaceId: workspaceId);
      companiesCubit.selectWorkspace(workspaceId: workspaceId);

      await channelsCubit.fetch(workspaceId: workspaceId);
      SynchronizationService.instance.subscribeToBadges();
    }

    if (workspaceId != null && workspaceId == 'direct') {
      directsCubit.selectChannel(channelId: channelId);

      Get.toNamed(RoutePaths.directMessages.path)?.then((_) {
        channelMessagesCubit.reset();
        directsCubit.clearSelection();
      });
    } else {
      channelsCubit.selectChannel(channelId: channelId);

      Get.toNamed(RoutePaths.channelMessages.path)?.then((_) {
        channelMessagesCubit.reset();
        channelsCubit.clearSelection();
      });
    }

    channelMessagesCubit.fetch(channelId: channelId);

    if (threadId != null) {
      channelMessagesCubit.selectThread(messageId: threadId);
      Get.toNamed(RoutePaths.messageThread.path)?.then((_) {
        channelMessagesCubit.clearSelectedThread();
        threadMessagesCubit.reset();
      });
      await threadMessagesCubit.fetch(channelId: channelId, threadId: threadId);
    }
  }

  Future<void> navigateToAccount({bool shouldShowInfo = false}) async {
    await accountCubit.fetch();
    Get.toNamed(shouldShowInfo
        ? RoutePaths.accountInfo.path
        : RoutePaths.accountSettings.path);
  }

  void openTwakeWebView(String url) {
    Get.to(TwakeWebView(url));
  }
}
