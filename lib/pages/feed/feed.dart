import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/pages/feed/channels.dart';
import 'package:twake/pages/feed/directs.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/common/decorated_tab_bar.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with SingleTickerProviderStateMixin {
  TabController _controller;
  final _tabs = [Channels(), Directs()];

  var _companiesHidden = true;
  var _canCreateWorkspace = false;
  var _companies = <Company>[];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _create() {
    context.read<SheetBloc>()
      ..add(SetFlow(
        flow: _controller.index != 0 ? SheetFlow.direct : SheetFlow.addChannel,
      ))
      ..add(OpenSheet());
  }

  void _showWorkspaces() {
    context.read<SheetBloc>()
      ..add(SetFlow(
        flow: SheetFlow.selectWorkspace,
      ))
      ..add(OpenSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        toolbarHeight: 160.0,
        title: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0,
              child: BlocBuilder<WorkspacesBloc, WorkspaceState>(
                buildWhen: (_, current) => current is WorkspacesLoaded,
                builder: (context, state) {
                  Workspace selectedWorkspace;
                  if (state is WorkspacesLoaded) {
                    selectedWorkspace = state.selected;
                  }
                  return GestureDetector(
                    onTap: () => _showWorkspaces(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        SizedBox(width: 9.0),
                        RoundedImage(
                          selectedWorkspace.logo,
                          width: 40.0,
                          height: 40.0,
                        ),
                        SizedBox(width: 15.0),
                        Expanded(
                          child: ShimmerLoading(
                            key: ValueKey<String>('name'),
                            isLoading: selectedWorkspace.name == null,
                            width: MediaQuery.of(context).size.width,
                            height: 10.0,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    selectedWorkspace.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black,
                                    size: 25.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _create(),
                          child: Image.asset('assets/images/create.png'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Search bar will be here.
          ],
        ),
        bottom: DecoratedTabBar(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xffd8d8d8).withOpacity(0.22),
                width: 2.0,
              ),
            ),
          ),
          tabBar: TabBar(
            controller: _controller,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 15.0),
            indicatorColor: Color(0xff004dff),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(
              color: Color(0xff8e8e93),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Tab(
                  text: 'Channels',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Tab(
                  text: 'Direct chats',
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _controller,
          children: _tabs,
        ),
      ),
    );
  }
}
