import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/push_notifications_service.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';
import 'home_channel_list_widget.dart';
import 'home_direct_list_widget.dart';
import 'home_drawer_widget.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget() : super();

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  String _searchText = "";
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (Globals.instance.token == null) return;

    if (state == AppLifecycleState.resumed) {
      SocketIOService.instance.connect();
      Future.delayed(Duration(seconds: 5), () {
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

  void refetchData() {
    Get.find<CompaniesCubit>().fetch();
    Get.find<WorkspacesCubit>().fetch(companyId: Globals.instance.companyId);

    Get.find<ChannelsCubit>().fetch(
      workspaceId: Globals.instance.workspaceId!,
      companyId: Globals.instance.companyId,
    );
    Get.find<DirectsCubit>().fetch(
      workspaceId: 'direct',
      companyId: Globals.instance.companyId,
    );

    Get.find<AccountCubit>().fetch();

    Get.find<BadgesCubit>().fetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: HomeDrawerWidget(),
        appBar: AppBar(
          leading: SizedBox.shrink(),
          leadingWidth: 0,
          toolbarHeight: kToolbarHeight + 100,
          bottom: TabBar(
            tabs: [
              BlocBuilder<WorkspacesCubit, WorkspacesState>(
                bloc: Get.find<WorkspacesCubit>(),
                builder: (_s, _) => Tab(
                  child: BadgesCount(
                    type: BadgeType.workspace,
                    id: Globals.instance.workspaceId!,
                  ),
                ),
              ),
              BlocBuilder<WorkspacesCubit, WorkspacesState>(
                bloc: Get.find<WorkspacesCubit>(),
                builder: (_s, _) => Tab(
                  child: BadgesCount(
                    type: BadgeType.workspace,
                    id: Globals.instance.workspaceId!,
                    isInDirects: true,
                  ),
                ),
              ),
            ],
            isScrollable: true,
            indicatorColor: Color(0xff004dff),
            unselectedLabelColor: Color(0xff8e8e93),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
            ),
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
            ),
          ),
          title: _buildHeader(),
        ),
        body: Stack(
          children: [
            Positioned(
              child: Opacity(
                opacity: 0.6,
                child: Divider(
                  height: 4,
                  color: Color(0xffd8d8d8),
                ),
              ),
            ),
            TabBarView(
              children: [
                HomeChannelListWidget(serchText: _searchText),
                HomeDirectListWidget(serchText: _searchText)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                                    imageUrl:
                                        workspaceState.selected?.logo ?? '',
                                    size: 42,
                                    name: workspaceState.selected?.name ?? '',
                                    backgroundColor: Color(0xfff5f5f5)),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
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
                  ),
                ),
                BlocBuilder(
                  bloc: Get.find<CompaniesCubit>(),
                  builder: (ctx, cstate) => (cstate is CompaniesLoadSuccess &&
                          cstate.selected.canUpdateChannel)
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => push(RoutePaths.newDirect.path),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                color: Color(0xfff9f8f9),
                                width: 40,
                                height: 40,
                                child: Image.asset(
                                  imageAddChannel,
                                  width: 20,
                                  height: 20,
                                  color: Color(0xff004dff),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.white,
            height: 12,
          ),
          TwakeSearchTextField(
            height: 40,
            controller: _searchController,
            hintText: AppLocalizations.of(context)!.search,
            backgroundColor: Color(0xfff9f8f9),
          ),
        ],
      ),
    );
  }
}
