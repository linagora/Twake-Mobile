import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/companies_bloc/companies_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/models/company.dart';
import 'package:twake/pages/feed/channels.dart';
import 'package:twake/pages/feed/directs.dart';
import 'package:twake/widgets/common/decorated_tab_bar.dart';
import 'package:twake/widgets/common/image_avatar.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        toolbarHeight: 160.0,
        title: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              color: Colors.blue.withOpacity(0.3),
              child: BlocBuilder<CompaniesBloc, CompaniesState>(
                buildWhen: (_, current) => current is CompaniesLoaded,
                builder: (context, state) {
                  if (state is CompaniesLoaded) {
                    _companies = state.companies;

                    final selectedCompany = state.selected;
                    final permissions = selectedCompany.permissions;
                    if (permissions.length > 0 &&
                        permissions.contains('CREATE_WORKSPACES')) {
                      _canCreateWorkspace = true;
                    } else {
                      _canCreateWorkspace = false;
                    }
                  }
                  return BlocBuilder<WorkspacesBloc, WorkspaceState>(
                    buildWhen: (_, current) => current is WorkspacesLoaded,
                    builder: (context, state) {
                      if (state is WorkspacesLoaded) {
                        final selectedWorkspace = state.selected;
                        final workspaces = state.workspaces;
                        if (selectedWorkspace != null) {
                          // TODO!
                        }
                      }
                      return Row(
                        children: [
                          // ImageAvatar(
                          //   state.workspaces[i].logo,
                          //   width: 40,
                          //   height: 40,
                          // ),
                          SizedBox(width: 15),
                          Text(
                            'WorkspaceName',
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () => print('Create channel!'),
                            child: Image.asset('assets/images/create.png'),
                          )
                        ],
                      );
                    },
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
