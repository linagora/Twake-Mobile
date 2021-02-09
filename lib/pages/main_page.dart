import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/bars/main_app_bar.dart';
import 'package:twake/widgets/channel/channels_group.dart';
import 'package:twake/widgets/channel/direct_messages_group.dart';
import 'package:twake/widgets/drawer/twake_drawer.dart';
import 'package:twake/widgets/sheets/draggable_scrollable.dart';

class MainPage extends StatefulWidget {
  const MainPage();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final PanelController _panelController = PanelController();

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
        backdropEnabled: true,
        renderPanelSheet: false,
        panel: BlocConsumer<SheetBloc, SheetState>(
          listenWhen: (_, current) =>
              current is SheetShouldOpen || current is SheetShouldClose,
          listener: (context, state) {
            // print('Strange state: $state');
            if (state is SheetShouldOpen) {
              if (_panelController.isPanelClosed) {
                _openSheet();
              }
            } else if (state is SheetShouldClose) {
              if (_panelController.isPanelOpen) {
                _closeSheet();
              }
            }
          },
          buildWhen: (_, current) => current is FlowUpdated,
          builder: (context, state) {
            var sheetFlow = SheetFlow.addChannel;
            if (state is FlowUpdated) {
              sheetFlow = state.flow;
              return DraggableScrollable(flow: sheetFlow);
            } else {
              return SizedBox();
            }
          },
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: Dim.heightPercent(
                  (kToolbarHeight * 0.15).round(),
                ),
                child: MainAppBar(
                  scaffoldKey: _scaffoldKey,
                ),
              ),
              Expanded(
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
                            )
                          : Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSheet() {
    _panelController.open();
  }

  void _closeSheet() {
    _panelController.close();
  }

  _onPanelSlide(double position) {
    if (position < 0.4 && _panelController.isPanelAnimating) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}
