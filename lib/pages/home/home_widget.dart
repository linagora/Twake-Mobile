import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/receive_sharing/receive_sharing_type.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/push_notifications_service.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/platform_detection.dart';
import 'package:twake/utils/receive_sharing_file_manager.dart';
import 'package:twake/utils/receive_sharing_text_manager.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/home_header.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

import 'home_channel_list_widget.dart';
import 'home_direct_list_widget.dart';
import 'home_drawer_widget.dart';

class HomeWidget extends StatefulWidget {
  // In case fetching companies inside refetchData() failed,
  // allow user to Retry fetch again, then join magic link and
  // select correct company/workspace after joined
  // This [magicLinkJoinResponse] help to cache magic link token
  // from previous state (AuthenticationSuccess)
  final WorkspaceJoinResponse? magicLinkJoinResponse;

  const HomeWidget({this.magicLinkJoinResponse}) : super();

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  String _searchText = "";
  ReceivePort _fileDownloaderPort = ReceivePort();
  late ReceiveSharingFileManager _receiveSharingFileManager;
  late StreamSubscription _receiveSharingFileSubscription;
  late ReceiveSharingTextManager _receiveSharingTextManager;
  late StreamSubscription _receiveSharingTextSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    PushNotificationsService.instance.requestPermission();

    refetchData();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });

    _initFileDownloader();
    _handleReceiveSharing();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (Globals.instance.token == null) return;
    if (Globals.instance.handlingMagicLink) return;

    if (state == AppLifecycleState.resumed) {
      SocketIOService.instance.connect();
      Future.delayed(Duration(seconds: 7), () async {
        refetchData();

        SynchronizationService.instance.subscribeToBadges();
        SynchronizationService.instance.subscribeForChannels(
          companyId: Globals.instance.companyId!,
          workspaceId: Globals.instance.workspaceId!,
        );
        SynchronizationService.instance.subscribeForChannels(
          companyId: Globals.instance.companyId!,
          workspaceId: 'direct',
        );
      });
    }
  }

  void refetchData() async {
    final result = await Get.find<CompaniesCubit>().fetch();
    // User can do anything when no company found, notice to them
    if (!result) {
      Get.find<AuthenticationCubit>().notifyNoCompanyBelongToUser(
        magicLinkJoinResponse: widget.magicLinkJoinResponse,
      );
    }

    if (Globals.instance.companyId != null) {
      Get.find<WorkspacesCubit>().fetch(companyId: Globals.instance.companyId);

      if (Globals.instance.workspaceId != null) {
        Get.find<ChannelsCubit>().fetch(
          workspaceId: Globals.instance.workspaceId!,
          companyId: Globals.instance.companyId,
        );
        Get.find<DirectsCubit>().fetch(
          workspaceId: 'direct',
          companyId: Globals.instance.companyId,
        );
      }
    }

    Get.find<AccountCubit>().fetch();

    Get.find<BadgesCubit>().fetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _receiveSharingFileSubscription.cancel();
    _receiveSharingFileManager.dispose();
    _receiveSharingTextSubscription.cancel();
    _receiveSharingTextManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawerWidget(),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                HomeHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TwakeSearchTextField(
                    height: 40,
                    onPress: () => push(RoutePaths.search.path),
                    hintText: AppLocalizations.of(context)!.search,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                _buildTabBar(),
                Divider(
                  thickness: 1,
                  height: 4,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      HomeChannelListWidget(serchText: _searchText),
                      HomeDirectListWidget(serchText: _searchText)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildTabBar() => TabBar(
        tabs: [
          BlocBuilder<WorkspacesCubit, WorkspacesState>(
            bloc: Get.find<WorkspacesCubit>(),
            builder: (_s, _) => Tab(
              child: BadgesCount(
                type: BadgeType.workspace,
                id: Globals.instance.workspaceId ?? '',
                isTitleVisible: true,
              ),
            ),
          ),
          BlocBuilder<WorkspacesCubit, WorkspacesState>(
            bloc: Get.find<WorkspacesCubit>(),
            builder: (_s, _) => Tab(
              child: BadgesCount(
                type: BadgeType.workspace,
                id: Globals.instance.workspaceId ?? '',
                isInDirects: true,
                isTitleVisible: true,
              ),
            ),
          ),
        ],
        isScrollable: true,
        indicatorColor: Theme.of(context).colorScheme.surface,
        unselectedLabelColor: Theme.of(context).colorScheme.secondary,
        unselectedLabelStyle: Theme.of(context).textTheme.headline1!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
        labelStyle: Theme.of(context)
            .textTheme
            .headline3!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      );

  void _initFileDownloader() {
    if (!PlatformDetection.isMobileSupported()) return;
    _bindFileDownloadBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _bindFileDownloadBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _fileDownloaderPort.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindFileDownloadBackgroundIsolate();
      _bindFileDownloadBackgroundIsolate();
      return;
    }
    _fileDownloaderPort.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      if (status == DownloadTaskStatus.complete) {
        Get.find<FileDownloadCubit>()
            .handleAfterDownloaded(taskId: id, context: context);
      } else if (status == DownloadTaskStatus.failed) {
        Get.find<FileDownloadCubit>().handleDownloadFailed(taskId: id);
      }
    });
  }

  void _unbindFileDownloadBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  _handleReceiveSharing() {
    // handle file sharing
    _receiveSharingFileManager = Get.find<ReceiveSharingFileManager>();
    _receiveSharingFileSubscription =
        _receiveSharingFileManager.pendingListFiles.stream.listen((listFiles) {
      if (listFiles.isNotEmpty) {
        Get.find<ReceiveFileCubit>().setNewListFiles(listFiles);
        _popWhenIsChildOfSharingPage();
        NavigatorService.instance
            .navigateToReceiveSharing(fileType: ReceiveSharingType.MediaFile);
      }
    });

    // handle text sharing
    _receiveSharingTextManager = Get.find<ReceiveSharingTextManager>();
    _receiveSharingTextSubscription = _receiveSharingTextManager
        .pendingListText.stream
        .listen((receivedText) {
      if (receivedText.text.isNotEmpty) {
        Get.find<ReceiveFileCubit>().setNewText(receivedText);
        _popWhenIsChildOfSharingPage();
        NavigatorService.instance
            .navigateToReceiveSharing(fileType: ReceiveSharingType.Text);
      }
    });
  }

  void _popWhenIsChildOfSharingPage() {
    try {
      if (_isChildPageOfSharingPage()) {
        NavigatorService.instance.back();
      }
    } catch (e) {
      Logger().e('Error occurred during pop child page from sharing file:\n$e');
    }
  }

  bool _isChildPageOfSharingPage() {
    return Get.currentRoute == RoutePaths.shareFileList.path ||
        Get.currentRoute == RoutePaths.shareFileCompList.path ||
        Get.currentRoute == RoutePaths.shareFileWsList.path ||
        Get.currentRoute == RoutePaths.shareFileChannelList.path;
  }
}
