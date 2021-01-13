import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/channel/channels_group.dart';
import 'package:twake/widgets/channel/direct_messages_group.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/drawer/twake_drawer.dart';
import 'package:twake/widgets/sheets/draggable_scrollable.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Duration _duration = Duration(milliseconds: 400);
  final Tween<Offset> _tween = Tween(
    begin: Offset(0, 1),
    end: Offset(0, 0),
  );
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        ),
        // taking into account current appBar height to calculate a new one
        title:
            BlocBuilder<WorkspacesBloc, WorkspaceState>(builder: (ctx, state) {
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
        child: Stack(
          children: [
            // MainPage body
            BlocBuilder<ChannelsBloc, ChannelState>(
              builder: (ctx, state) =>
                  (state is ChannelsLoaded || state is ChannelsEmpty)
                      ? RefreshIndicator(
                          onRefresh: () {
                            BlocProvider.of<ChannelsBloc>(ctx)
                                .add(ReloadChannels(forceFromApi: true));
                            return Future.delayed(Duration(seconds: 1));
                          },
                          child: GestureDetector(
                            onTap: () => _closeSheet(),
                            behavior: HitTestBehavior.translucent,
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
                          ),
                        )
                      : Center(child: CircularProgressIndicator()),
            ),

            // Sheet for channel/direct adding
            BlocConsumer<SheetBloc, SheetState>(
              listener: (context, state) {
                if (state is SheetShouldOpen) {
                  _openSheet();
                }
                if (state is SheetShouldClose) {
                  _closeSheet();
                }
              },
              builder: (context, state) {
                // if (state is SheetShouldOpen || state is SheetShouldClose) {
                  // final flow = state.flow;

                  return SlideTransition(
                    position: _tween.animate(_animationController),
                    child: DraggableScrollable(),
                  );
                }
                // else {
                //   return SizedBox();
                // }
            ),
          ],
        ),
      ),
    );
  }

  void _openSheet() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    }
  }

  void _closeSheet() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }
}
