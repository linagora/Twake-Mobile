import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/events/channel_event.dart';
import 'package:twake/services/init.dart';
// import 'package:twake/services/service_bundle.dart';
import 'package:twake/widgets/drawer/twake_drawer.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/channel/channels_group.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/states/workspace_state.dart';
import 'package:twake/states/channel_state.dart';

class MainPage extends StatelessWidget {
  static const route = '/main';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final InitData data;
  MainPage(this.data);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>(create: (_) => ProfileBloc(data.profile)),
          BlocProvider<CompaniesBloc>(
            create: (ctx) => CompaniesBloc(data.companies),
          ),
          BlocProvider<WorkspacesBloc>(create: (ctx) {
            return WorkspacesBloc(
              repository: data.workspaces,
              companiesBloc: BlocProvider.of<CompaniesBloc>(ctx),
            );
          }),
          BlocProvider<ChannelsBloc>(create: (ctx) {
            return ChannelsBloc(
              repository: data.channels,
              workspacesBloc: BlocProvider.of<WorkspacesBloc>(ctx),
            );
          }),
        ],
        child: Scaffold(
            key: _scaffoldKey,
            drawer: TwakeDrawer(),
            appBar: AppBar(
              titleSpacing: 0.0,
              leading: IconButton(
                padding: EdgeInsets.only(left: Dim.wm3),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  size: Dim.tm4(),
                ),
              ),
              toolbarHeight: Dim.heightPercent(
                (kToolbarHeight * 0.15).round(),
              ), // taking into account current appBar height to calculate a new one
              title: BlocBuilder<WorkspacesBloc, WorkspaceState>(
                  builder: (ctx, state) {
                if (state is WorkspacesLoaded)
                  return Row(
                    children: [
                      ImageAvatar(state.selected.logo),
                      SizedBox(width: Dim.wm2),
                      Text(state.selected.logo,
                          style: Theme.of(context).textTheme.headline6),
                    ],
                  );
                else
                  return CircularProgressIndicator();
              }),
            ),
            body: BlocBuilder<ChannelsBloc, ChannelState>(
              builder: (ctx, state) => state is ChannelsLoaded
                  ? RefreshIndicator(
                      onRefresh: () {
                        BlocProvider.of<ChannelsBloc>(ctx)
                            .add(ReloadChannels(''));
                        return Future.delayed(Duration(seconds: 1));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dim.wm3,
                          vertical: Dim.heightMultiplier,
                        ),
                        child: ListView(
                          children: [
                            // Starred channels will be implemented in version 2
                            // StarredChannelsBlock([]),
                            // Divider(height: Dim.hm5),
                            ChannelsGroup(),
                            Divider(height: Dim.hm5),
                            // DirectMessagesBlock(directs),
                            SizedBox(height: Dim.hm2),
                          ],
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
            )),
      ),
    );
  }
}
