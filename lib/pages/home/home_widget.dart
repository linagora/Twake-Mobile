import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:twake/config/image_path.dart';
import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/push_notifications_service.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/receive_sharing_file_manager.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/rounded_shimmer.dart';
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
    _handleReceiveSharingFile();
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
    if(!result) {
      Get.find<AuthenticationCubit>().notifyNoCompanyBelongToUser(
        magicLinkJoinResponse: widget.magicLinkJoinResponse,
      );
    }

    if(Globals.instance.companyId != null) {
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
                _buildHeader(),
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 44,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
                    bloc: Get.find<WorkspacesCubit>(),
                    builder: (context, workspaceState) {
                      if (workspaceState is WorkspacesLoadSuccess) {
                        return GestureDetector(
                          onTap: () {
                            Get.find<AccountCubit>().fetch();
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            width: 75,
                            child: Row(
                              children: [
                                ImageWidget(
                                  imageType: ImageType.common,
                                  imageUrl: workspaceState.selected?.logo ?? '',
                                  size: 42,
                                  borderRadius: 10,
                                  name: workspaceState.selected?.name ?? '',
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.9),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: 75,
                          child: Row(
                            children: [
                              RoundedShimmer(size: 42),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.9),
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    imageTwakeHomeLogo,
                    width: 63,
                    height: 15,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.9),
                  ),
                ),
                _buildHeaderActionButtons()
              ],
            ),
          ),
          SizedBox(height: 12),
          TwakeSearchTextField(
            height: 40,
            controller: _searchController,
            hintText: AppLocalizations.of(context)!.search,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ],
      ),
    );
  }

  _buildHeaderActionButtons() => Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BlocBuilder(
                bloc: Get.find<CompaniesCubit>(),
                builder: (ctx, cstate) => (cstate is CompaniesLoadSuccess &&
                        cstate.selected.canShareMagicLink)
                    ? Row(
                        children: [
                          BlocBuilder<WorkspacesCubit, WorkspacesState>(
                            bloc: Get.find<WorkspacesCubit>(),
                            builder: (context, workspaceState) {
                              return workspaceState is WorkspacesLoadSuccess
                                  ? GestureDetector(
                                      onTap: () => push(
                                          RoutePaths.invitationPeople.path,
                                          arguments:
                                              workspaceState.selected?.name ??
                                                  ''),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          width: 40,
                                          height: 40,
                                          child: Image.asset(
                                            imageInvitePeople,
                                            width: 20,
                                            height: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink();
                            },
                          ),
                          SizedBox(width: 16),
                        ],
                      )
                    : SizedBox.shrink()),
            GestureDetector(
              onTap: () => push(RoutePaths.newDirect.path),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    imageAddChannel,
                    width: 20,
                    height: 20,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

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

  _handleReceiveSharingFile() {
    _receiveSharingFileManager = Get.find<ReceiveSharingFileManager>();
    _receiveSharingFileSubscription =
        _receiveSharingFileManager.pendingListFiles.stream.listen((listFiles) {
      if (listFiles.isNotEmpty) {
        Get.find<ReceiveFileCubit>().setNewListFiles(listFiles);
        _popWhenIsChildOfSharingPage();
        NavigatorService.instance.navigateToReceiveSharingFile(listFiles);
      }
    });
  }

  void _popWhenIsChildOfSharingPage() {
    try {
      if(_isChildPageOfSharingPage()) {
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
