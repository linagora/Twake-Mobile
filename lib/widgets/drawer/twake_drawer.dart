import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/image_avatar.dart';

const double ICON_SIZE_MULTIPLIER = 4.5;

class TwakeDrawer extends StatefulWidget {
  @override
  _TwakeDrawerState createState() => _TwakeDrawerState();
}

class _TwakeDrawerState extends State<TwakeDrawer> {
  bool _companiesHidden = true;
  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(
      horizontal: Dim.wm2,
      vertical: Dim.heightMultiplier,
    );
    return Container(
      width: Dim.widthPercent(80),
      child: Drawer(
        child: Container(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(left: Dim.wm3),
                title: Text(
                  _companiesHidden ? 'Workspaces' : 'Choose company',
                  style: Theme.of(context).textTheme.headline5,
                ), // TODO configure the styles
                trailing: _companiesHidden
                    ? IconButton(
                        color: Colors.black87,
                        onPressed: () {
                          setState(() {
                            _companiesHidden = false;
                          });
                        },
                        iconSize: Dim.tm4(),
                        icon: Icon(
                          Icons.loop,
                        ),
                      )
                    : SizedBox(width: 0, height: 0),
              ),
              Divider(),
              SizedBox(height: Dim.hm2),
              if (_companiesHidden)
                Container(
                  height: Dim.heightPercent(55),
                  child: BlocBuilder<WorkspacesBloc, WorkspaceState>(
                    builder: (ctx, state) => state is WorkspacesLoaded
                        ? ListView.builder(
                            itemCount: state.workspaces.length,
                            itemBuilder: (ctx, i) => InkWell(
                                  onTap: () {
                                    BlocProvider.of<WorkspacesBloc>(ctx).add(
                                        ChangeSelectedWorkspace(
                                            state.workspaces[i].id));
                                    Navigator.of(context).pop();
                                  },
                                  child: ListTile(
                                    leading:
                                        ImageAvatar(state.workspaces[i].logo),
                                    title: Text(
                                      state.workspaces[i].name,
                                    ),
                                    subtitle: Text(
                                        '${state.workspaces[i].totalMembers} members'),
                                  ),
                                ))
                        : CircularProgressIndicator(),
                  ),
                ),
              if (!_companiesHidden)
                Container(
                  height: Dim.heightPercent(55),
                  child: BlocBuilder<CompaniesBloc, CompaniesState>(
                      builder: (ctx, state) => state is CompaniesLoaded
                          ? ListView.builder(
                              itemCount: state.companies.length,
                              itemBuilder: (ctx, i) => InkWell(
                                    onTap: () {
                                      BlocProvider.of<CompaniesBloc>(ctx).add(
                                          ChangeSelectedCompany(
                                              state.companies[i].id));
                                      setState(() {
                                        _companiesHidden = true;
                                      });
                                    },
                                    child: ListTile(
                                      leading:
                                          ImageAvatar(state.companies[i].logo),
                                      title: Text(
                                        state.companies[i].name,
                                      ),
                                      subtitle: Text(
                                          '${state.companies[i].totalMembers} members'),
                                    ),
                                  ))
                          : CircularProgressIndicator()),
                ),
              Spacer(),
              Divider(),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (ctx, state) => state is ProfileLoaded
                    ? ListTile(
                        contentPadding: padding,
                        leading: ImageAvatar(state.thumbnail),
                        title: Text(
                          '${state.firstName} ${state.lastName}',
                          style: Theme.of(context).textTheme.headline5,
                        ), // TODO configure the styles
                        trailing: IconButton(
                          onPressed: () {
                            BlocProvider.of<AuthBloc>(ctx)
                                .add(ResetAuthentication());
                          },
                          color: Colors.black87,
                          icon: Icon(
                            Icons.logout,
                            size: Dim.tm4(),
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
