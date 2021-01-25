import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/bars/main_app_bar.dart';
import 'package:twake/widgets/channel/channels_group.dart';
import 'package:twake/widgets/channel/direct_messages_group.dart';
import 'package:twake/widgets/drawer/twake_drawer.dart';
import 'package:twake/widgets/sheets/draggable_scrollable.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    // _animationController.addStatusListener((status) {
    //   if (status == AnimationStatus.dismissed) {
    //     context.read<SheetBloc>().add(SetClosed());
    //     FocusScope.of(context).requestFocus(new FocusNode());
    //   }
    //   if (status == AnimationStatus.completed) {
    //     context.read<SheetBloc>().add(SetOpened());
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: TwakeDrawer(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        controller: _panelController,
        onPanelOpened: () => context.read<SheetBloc>().add(SetOpened()),
        onPanelClosed: () => context.read<SheetBloc>().add(SetClosed()),
        onPanelSlide: _onPanelSlide,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        snapPoint: 0.4,
        backdropEnabled: true,
        renderPanelSheet: false,
        panel: BlocBuilder<SheetBloc, SheetState>(
            buildWhen: (_, current) =>
                current is SheetShouldOpen || current is SheetShouldClose,
            builder: (context, state) {
              if (state is SheetShouldOpen) {
                _openSheet();
              } else if (state is SheetShouldClose) {
                _closeSheet();
              }
              return DraggableScrollable();
            }),
        body: SafeArea(
          child: Column(
            children: [
              MainAppBar(
                scaffoldKey: _scaffoldKey,
              ),
              Expanded(
                child: BlocListener<ChannelsBloc, ChannelState>(
                  listener: (ctx, state) {
                    if (state is ErrorLoadingChannels)
                      Scaffold.of(ctx).showSnackBar(SnackBar(
                        content: Text('No connection to internet'),
                        backgroundColor: Theme.of(ctx).errorColor,
                      ));
                  },
                  child: BlocBuilder<ChannelsBloc, ChannelState>(
                    builder: (ctx, state) =>
                        (state is ChannelsLoaded || state is ChannelsEmpty)
                            ? RefreshIndicator(
                                onRefresh: () {
                                  BlocProvider.of<ChannelsBloc>(ctx)
                                      .add(ReloadChannels(forceFromApi: true));
                                  BlocProvider.of<DirectsBloc>(ctx)
                                      .add(ReloadChannels(forceFromApi: true));
                                  return Future.delayed(Duration(seconds: 1));
                                },
                                child: GestureDetector(
                                  onTap: () => _closeSheet(),
                                  behavior: HitTestBehavior.translucent,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: ListView(
                                      padding: EdgeInsets.only(top: 0),
                                      children: [
                                        // Starred channels will be implemented in version 2
                                        // StarredChannelsBlock([]),
                                        // Divider(height: Dim.hm5),
                                        ChannelsGroup(),
                                        Divider(
                                          thickness: 2.0,
                                          height: 2.0,
                                          color: Color(0xffEEEEEE),
                                        ),
                                        SizedBox(height: 8),
                                        DirectMessagesGroup(),
                                        Divider(
                                          thickness: 2.0,
                                          height: 2.0,
                                          color: Color(0xffEEEEEE),
                                        ),
                                        SizedBox(height: Dim.hm2),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // Sheet for channel/direct adding
  // BlocConsumer<SheetBloc, SheetState>(
  // listener: (context, state) {
  // if (state is SheetShouldOpen) {
  // _openSheet();
  // }
  // if (state is SheetShouldClose) {
  // _closeSheet();
  // }
  // },
  // builder: (context, state) {
  // return SlideTransition(
  // position: _tween.animate(_animationController),
  // child: DraggableScrollable(),
  // );
  // },
  // ),

  void _openSheet() {
    _panelController.open();
    // if (_animationController.isDismissed) {
    //   _animationController.forward();
    // }
    // setState(() {
    //   _shouldBlur = true;
    // });
  }

  void _closeSheet() {
    _panelController.close();
    // if (_animationController.isCompleted) {
    //   _animationController.reverse();
    // }
    // setState(() {
    //   _shouldBlur = false;
    // });
  }

  _onPanelSlide(double position) {

    // if (position < 0.2) {
    //   panelProvider.updateExpandPanel(false);
    // } else if (position > 0.2 && !panelProvider.expandPanel) {
    //   panelProvider.updateExpandPanel(true);
    // }
  }
}
