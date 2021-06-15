import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/globals/globals.dart';
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
        companyId: Globals.instance.companyId);

    Get.find<AccountCubit>().fetch();
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
            toolbarHeight: kToolbarHeight + 80,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Channels'),
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
          body: TabBarView(
            children: [
              HomeChannelListWidget(),
              HomeDirectListWidget(),
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
                            child: Row(
                              children: [
                                RoundedImage(
                                  borderRadius: BorderRadius.circular(10),
                                  width: 36,
                                  height: 36,
                                  imageUrl: workspaceState.selected?.logo ?? '',
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black)
                              ],
                            ),
                          );
                        }
                        return TwakeCircularProgressIndicator();
                      }),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      imageTwakeHomeLogo,
                      width: 63,
                      height: 15,
                    ))
              ],
            ),
          ),
          Divider(
            color: Colors.white,
            height: 12,
          ),
          HomeSearchTextField(),
        ],
      ),
    );
  }
}

class HomeSearchTextField extends StatelessWidget {
  const HomeSearchTextField() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      child: TextField(
        cursorColor: Color(0xff004dff),
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefixIcon: Icon(Icons.search),
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            hintStyle: TextStyle(
              color: Color(0xff8e8e93),
              fontSize: 17,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            hintText: "Search",
            fillColor: Color(0xfff9f8f9)),
      ),
    );
  }
}
