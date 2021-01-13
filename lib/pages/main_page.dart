import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/channel/channels_group.dart';
import 'package:twake/widgets/channel/direct_messages_group.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/drawer/twake_drawer.dart';

class MainPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          backgroundColor: Colors.white,
          toolbarHeight: Dim.heightPercent(
            (kToolbarHeight * 0.15).round(),
          ), // taking into account current appBar height to calculate a new one
          title: BlocBuilder<WorkspacesBloc, WorkspaceState>(
              builder: (ctx, state) {
            if (state is WorkspacesLoaded)
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ImageAvatar(state.selected.logo),
                title: Text(
                  state.selected.name,
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            else
              return CircularProgressIndicator();
          }),
        ),
        body: SafeArea(
          child: BlocBuilder<ChannelsBloc, ChannelState>(
            builder: (ctx, state) =>
                (state is ChannelsLoaded || state is ChannelsEmpty)
                    ? RefreshIndicator(
                        onRefresh: () {
                          BlocProvider.of<ChannelsBloc>(ctx)
                              .add(ReloadChannels(forceFromApi: true));
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
                              DirectMessagesGroup(),
                              SizedBox(height: Dim.hm2),
                            ],
                          ),
                        ),
                      )
                    : Center(child: CircularProgressIndicator()),
          ),
        ));
  }
}
