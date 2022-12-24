import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/receive_sharing/receive_sharing_file.dart';
import 'package:twake/models/receive_sharing/receive_sharing_type.dart';
import 'package:twake/pages/companies/company_selection_widget.dart';
import 'package:twake/pages/home/home_widget.dart';
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
  final PinnedMessageCubit pinnedMessageCubit;

  final BadgesCubit badgesCubit;

  factory NavigatorService({
    required AccountCubit accountCubit,
    required CompaniesCubit companiesCubit,
    required WorkspacesCubit workspacesCubit,
    required ChannelsCubit channelsCubit,
    required DirectsCubit directsCubit,
    required ChannelMessagesCubit channelMessagesCubit,
    required ThreadMessagesCubit threadMessagesCubit,
    required PinnedMessageCubit pinnedMessageCubit,
    required BadgesCubit badgesCubit,
  }) {
    _service = NavigatorService._(
      accountCubit: accountCubit,
      companiesCubit: companiesCubit,
      workspacesCubit: workspacesCubit,
      channelsCubit: channelsCubit,
      directsCubit: directsCubit,
      channelMessagesCubit: channelMessagesCubit,
      pinnedMessageCubit: pinnedMessageCubit,
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
    required this.pinnedMessageCubit,
    required this.badgesCubit,
  }) {
    // Run the notification click listeners
    listenToLocals();
    listenToRemote();
  }

  static NavigatorService get instance => _service;

  Future<void> navigateOnNotificationLaunch() async {
    await Future.delayed(Duration(milliseconds: 700));
    final local = await _pushNotifications.checkLocalNotificationClick;
    if (local != null) {
      final data = NotificationPayload.fromJson(json: local.payload);
      navigateNotification(
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
      navigateNotification(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId == data.messageId ? null : data.threadId,
      );
    }
  }

  void listenToLocals() async {
    await for (final local in _pushNotifications.localNotifications) {
      if (local.type != LocalNotificationType.message) continue;
      final data = NotificationPayload.fromJson(json: local.payload);
      Get.back(closeOverlays: true);
      navigateNotification(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId == data.messageId ? null : data.threadId,
      );
    }
  }

  void listenToRemote() async {
    await for (final remote in _pushNotifications.notificationClickStream) {
      final data = remote.payload;

      Get.back(closeOverlays: true);
      navigateNotification(
        companyId: data.companyId,
        workspaceId: data.workspaceId,
        channelId: data.channelId,
        threadId: data.threadId == data.messageId ? null : data.threadId,
      );
    }
  }

  Future<void> navigateToChannel(
      {required String channelId, bool isReconnection: false}) async {
    final channel = await directsCubit.getChannel(channelId: channelId);
    pinnedMessageCubit.init();
    if (!isReconnection) channelMessagesCubit.reset();

    channelMessagesCubit.fetch(
        channelId: channelId, isDirect: channel.isDirect);

    pinnedMessageCubit.getPinnedMessages(channelId, channel.isDirect);

    if (channel.isDirect) {
      channelsCubit.clearSelection();
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
  }

  Future<void> navigateToThread(
      {required String channelId, required String threadId}) async {
    if (threadId.isNotEmpty) {
      Globals.instance.threadIdSet = threadId;

      final channel = await directsCubit.getChannel(channelId: channelId);

      threadMessagesCubit.fetch(
        channelId: channelId,
        threadId: threadId,
        isDirect: channel.isDirect,
      );

      pinnedMessageCubit.getPinnedMessages(channelId, channel.isDirect);

      final path = channel.isDirect
          ? RoutePaths.directMessageThread.path
          : RoutePaths.channelMessageThread.path;

      Get.toNamed(path)?.then((_) {
        threadMessagesCubit.reset();
      });
    }
  }

  void navigateNotification({
    required String companyId,
    required String workspaceId,
    required String channelId,
    required String? threadId,
  }) async {
    companiesCubit.selectCompany(companyId: companyId);
    await workspacesCubit.fetch(companyId: companyId, localOnly: true);
    await directsCubit.fetch(
      companyId: companyId,
      workspaceId: 'direct',
      localOnly: true,
    );
    if (workspaceId != 'direct')
      workspacesCubit.selectWorkspace(workspaceId: workspaceId);
    await channelsCubit.fetch(
        companyId: companyId, workspaceId: workspaceId, localOnly: true);
    if (workspaceId != 'direct')
      companiesCubit.selectWorkspace(workspaceId: workspaceId);

    threadId == null
        ? navigateToChannel(channelId: channelId)
        : navigateToThread(channelId: channelId, threadId: threadId);
  }

  void pop<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    Get.back(
        result: result, closeOverlays: closeOverlays, canPop: canPop, id: id);
  }

  Future<void> navigateToChannelAfterSharedFile({
    required String companyId,
    required String workspaceId,
    required String channelId,
  }) async {
    if (companyId != Globals.instance.companyId) {
      final result = await Get.find<CompaniesCubit>().fetch();
      if (!result) return;
      companiesCubit.selectCompany(companyId: companyId);

      await workspacesCubit.fetch(companyId: companyId, localOnly: true);
      await directsCubit.fetch(
        companyId: companyId,
        workspaceId: 'direct',
        localOnly: true,
      );
    }

    workspacesCubit.selectWorkspace(workspaceId: workspaceId);
    companiesCubit.selectWorkspace(workspaceId: workspaceId);

    await channelsCubit.fetch(
      companyId: companyId,
      workspaceId: workspaceId,
      localOnly: true,
    );
    SynchronizationService.instance.subscribeToBadges();

    final channel = await directsCubit.getChannel(channelId: channelId);
    if (channel.isDirect) {
      directsCubit.selectChannel(channelId: channelId);
    } else {
      channelsCubit.selectChannel(channelId: channelId);
    }
    channelMessagesCubit.reset();
    await channelMessagesCubit.fetch(
        channelId: channelId, isDirect: channel.isDirect);
    pinnedMessageCubit.getPinnedMessages(channelId, channel.isDirect);

    if (channel.isDirect) {
      Get.toNamed(RoutePaths.directMessages.path)?.then((_) {
        directsCubit.clearSelection();
      });
    } else {
      Get.toNamed(RoutePaths.channelMessages.path)?.then((_) {
        channelsCubit.clearSelection();
      });
    }
    badgesCubit.reset(channelId: channelId);
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

  Future<void> navigateToChannelFiles(Channel channel) async {
    Get.toNamed(RoutePaths.channelFiles.path, arguments: channel);
  }

  Future<void> navigateToInvitationPeople(String workspaceName) async {
    Get.toNamed(RoutePaths.invitationPeople.path, arguments: workspaceName);
  }

  Future<void> navigateToInvitationPeopleEmail(String invitationUrl) async {
    Get.toNamed(RoutePaths.invitationPeopleEmail.path,
        arguments: invitationUrl);
  }

  Future<void> navigateToFilePreview({
    String? channelId,
    File? file,
    MessageFile? messageFile,
    bool? enableDownload,
    bool? isImage,
  }) async {
    if (channelId == null) {
      Get.toNamed(
        RoutePaths.directFilePreview.path,
        arguments: [file == null ? messageFile : file, enableDownload, isImage],
      );
    } else {
      if (file == null && messageFile == null) return;
      final channel = await directsCubit.getChannel(channelId: channelId);
      if (channel.isDirect) {
        Get.toNamed(
          RoutePaths.directFilePreview.path,
          arguments: [
            file == null ? messageFile : file,
            enableDownload,
            isImage
          ],
        );
      } else {
        Get.toNamed(
          RoutePaths.channelFilePreview.path,
          arguments: [
            file == null ? messageFile : file,
            enableDownload,
            isImage
          ],
        );
      }
    }
  }

  Future<void> navigateToReceiveSharing(
      {required ReceiveSharingType fileType}) async {
    Get.toNamed(RoutePaths.shareFile.path, arguments: fileType);
  }

  Future<void> navigateToReceiveSharingFileList(
      List<ReceiveSharingFile> listFiles) async {
    Get.toNamed(RoutePaths.shareFileList.path, arguments: listFiles);
  }

  Future<dynamic> navigateToReceiveSharingCompanyList() async {
    return await Get.toNamed(RoutePaths.shareFileCompList.path);
  }

  Future<dynamic> navigateToReceiveSharingWSList() async {
    return await Get.toNamed(RoutePaths.shareFileWsList.path);
  }

  Future<dynamic> navigateToReceiveSharingChannelList() async {
    return await Get.toNamed(RoutePaths.shareFileChannelList.path);
  }

  Future<void> navigateToHome() async {
    Get.offAll(
      () => HomeWidget(),
      transition: Transition.native,
    );
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
