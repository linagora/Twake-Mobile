import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/pages/companies/company_selection_widget.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/pages/twake_web_view.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/widgets/common/warning_dialog.dart';

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
  final BadgesCubit badgesCubit;

  factory NavigatorService({
    required AccountCubit accountCubit,
    required CompaniesCubit companiesCubit,
    required WorkspacesCubit workspacesCubit,
    required ChannelsCubit channelsCubit,
    required DirectsCubit directsCubit,
    required ChannelMessagesCubit channelMessagesCubit,
    required ThreadMessagesCubit threadMessagesCubit,
    required BadgesCubit badgesCubit,
  }) {
    _service = NavigatorService._(
      accountCubit: accountCubit,
      companiesCubit: companiesCubit,
      workspacesCubit: workspacesCubit,
      channelsCubit: channelsCubit,
      directsCubit: directsCubit,
      channelMessagesCubit: channelMessagesCubit,
      threadMessagesCubit: threadMessagesCubit,
      badgesCubit: badgesCubit,
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
    required this.badgesCubit,
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
    if (companyId != null && companyId != Globals.instance.companyId) {
      companiesCubit.selectCompany(companyId: companyId);

      workspacesCubit.fetch(companyId: companyId, localOnly: true);

      await directsCubit.fetch(
        companyId: companyId,
        workspaceId: 'direct',
        localOnly: true,
      );
    }

    if (workspaceId != null &&
        workspaceId != 'direct' &&
        workspaceId != Globals.instance.workspaceId) {
      workspacesCubit.selectWorkspace(workspaceId: workspaceId);
      companiesCubit.selectWorkspace(workspaceId: workspaceId);

      await channelsCubit.fetch(workspaceId: workspaceId, localOnly: true);

      SynchronizationService.instance.subscribeToBadges();
    }

    final channel = await directsCubit.getChannel(channelId: channelId);

    channelMessagesCubit.reset();
    channelMessagesCubit.fetch(
      channelId: channelId,
      isDirect: channel.isDirect,
      empty: channel.lastMessage == null,
    );

    if (channel.isDirect) {
      directsCubit.selectChannel(channelId: channelId);

      Get.toNamed(RoutePaths.directMessages.path)?.then((_) {
        directsCubit.clearSelection();
      });
    } else {
      channelsCubit.selectChannel(channelId: channelId);

      Get.toNamed(RoutePaths.channelMessages.path)?.then((_) {
        channelsCubit.clearSelection();
      });
    }

    badgesCubit.reset(channelId: channelId);

    if (threadId != null && threadId.isNotEmpty) {
      channelMessagesCubit.selectThread(messageId: threadId);

      final path = channel.isDirect
          ? RoutePaths.directMessageThread.path
          : RoutePaths.channelMessageThread.path;

      Get.toNamed(path)?.then((_) {
        channelMessagesCubit.clearSelectedThread();
        threadMessagesCubit.reset();
      });

      threadMessagesCubit.fetch(
        channelId: channelId,
        threadId: threadId,
        isDirect: channel.isDirect,
      );
    }
  }

  Future<void> navigateToAccount({bool shouldShowInfo = false}) async {
    accountCubit.fetch();
    Get.toNamed(
      shouldShowInfo
          ? RoutePaths.accountInfo.path
          : RoutePaths.accountSettings.path,
    );
  }

  Future<void> navigateToCreateWorkspace() async {
    Get.toNamed(RoutePaths.createWorkspace.path);
  }

  Future<void> navigateTohomeWidget() async {
    Get.find<WorkspacesCubit>().fetch();
    Get.toNamed(RoutePaths.homeWidget.path);
  }

  Future<void> navigateToChannelDetail() async {
    Get.toNamed(RoutePaths.channelDetail.path);
  }

  Future<void> navigateToEditChannel(Channel channel) async {
    Get.toNamed(RoutePaths.editChannel.path, arguments: channel);
  }

  Future<void> navigateToChannelMemberManagement(Channel channel) async {
    Get.toNamed(RoutePaths.channelMemberManagement.path, arguments: channel);
  }

  Future<void> navigateToChannelSetting(Channel channel) async {
    Get.toNamed(RoutePaths.channelSettings.path, arguments: channel);
  }

  void openTwakeWebView(String url) {
    Get.to(TwakeWebView(url));
  }

  Future<void> back({bool shouldLogout = false}) async {
    if (shouldLogout) {
      Get.offAll(
        () => InitialPage(),
        transition: Transition.leftToRight,
      );
    } else {
      Get.back();
    }
  }

  Future<void> showCompanies() async {
    Get.bottomSheet(CompanySelectionWidget());
  }

  Future<void> showWarning(String message) async {
    Get.dialog(
      WarningDialog(
        title: 'Error\n$message',
        trailingActionTitle: 'Close',
        trailingAction: () => Get.back(),
      ),
    );
  }
}
