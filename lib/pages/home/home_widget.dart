import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

import 'home_channel_list_widget.dart';
import 'home_direct_list_widget.dart';
import 'home_drawer_widget.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget() : super();

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();

    Get.find<CompaniesCubit>().fetch();
    Get.find<WorkspacesCubit>().fetch(companyId: Globals.instance.companyId);

    Get.find<ChannelsCubit>().fetch(
      workspaceId: Globals.instance.workspaceId!,
      companyId: Globals.instance.companyId,
    );
    Get.find<DirectsCubit>().fetch(
      workspaceId: Globals.instance.workspaceId!,
      companyId: Globals.instance.companyId,
    );

    Get.find<AccountCubit>().fetch(sendAnalyticAfterFetch: true);

    Get.find<BadgesCubit>().fetch();
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
            toolbarHeight: kToolbarHeight + 44,
            bottom: TabBar(
              tabs: [
                Tab(
                  child: BadgesCount(
                    type: BadgeType.workspace,
                    id: Globals.instance.workspaceId!,
                  ),
                ),
                Tab(
                  text: 'Chats',
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

          /* float button to create channel
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: FloatingActionButton(
              onPressed: () => push(RoutePaths.newChannel.path),
              backgroundColor: Color(0xff004dff),
              child: Image.asset(imageAddChannel),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
           */

          body: Stack(
            children: [
              Positioned(
                  child: Opacity(
                      opacity: 0.22,
                      child: Divider(
                        height: 2,
                        color: Color(0xffd8d8d8),
                      ))),
              TabBarView(
                children: [
                  HomeChannelListWidget(),
                  HomeDirectListWidget(),
                ],
              )
            ],
          )),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 36,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
                    bloc: Get.find<WorkspacesCubit>(),
                    builder: (context, workspaceState) {
                      if (workspaceState is WorkspacesLoadSuccess) {
                        return GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Container(
                            width: 75,
                            child: Row(
                              children: [
                                RoundedImage(
                                  borderRadius: 10.0,
                                  width: 36,
                                  height: 36,
                                  imageUrl: workspaceState.selected?.logo ?? '',
                                ),
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
                      }
                      return TwakeCircularProgressIndicator();
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
                Align(
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
                            ))),
                  ),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.white,
            height: 12,
          ),
        ],
      ),
    );
  }
}

