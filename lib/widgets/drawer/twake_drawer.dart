import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/blocs/workspaces_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:webview_flutter/webview_flutter.dart';

const double ICON_SIZE_MULTIPLIER = 4.5;

class TwakeDrawer extends StatefulWidget {
  @override
  _TwakeDrawerState createState() => _TwakeDrawerState();
}

class _TwakeDrawerState extends State<TwakeDrawer> {
  bool _companiesHidden = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dim.widthPercent(80),
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    Text(
                      _companiesHidden ? 'Workspaces' : 'Choose company',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff444444),
                      ),
                    ),
                    Spacer(),
                    _companiesHidden
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
                  ],
                ),
              ),
              Divider(
                thickness: 2.0,
                height: 2.0,
                color: Color(0xffEEEEEE),
              ),
              SizedBox(height: Dim.hm2),
              if (_companiesHidden)
                Expanded(
                  child: BlocBuilder<WorkspacesBloc, WorkspaceState>(
                    builder: (ctx, state) => state is WorkspacesLoaded
                        ? ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            itemCount: state.workspaces.length,
                            itemBuilder: (ctx, i) => InkWell(
                                  onTap: () {
                                    BlocProvider.of<WorkspacesBloc>(ctx).add(
                                        ChangeSelectedWorkspace(
                                            state.workspaces[i].id));
                                    Navigator.of(context).pop();
                                  },
                                  child: SizedBox(
                                    height: 62,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ImageAvatar(
                                          state.workspaces[i].logo,
                                          width: 30,
                                          height: 30,
                                        ),
                                        SizedBox(width: 15),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 12),
                                            Text(
                                              state.workspaces[i].name,
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff444444),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${state.workspaces[i].totalMembers} members',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff444444),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                        : CircularProgressIndicator(),
                  ),
                ),
              if (!_companiesHidden)
                Expanded(
                  child: BlocBuilder<CompaniesBloc, CompaniesState>(
                      builder: (ctx, state) => state is CompaniesLoaded
                          ? ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 15),
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ImageAvatar(
                                      state.companies[i].logo,
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 15),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 12),
                                        Text(
                                          state.companies[i].name,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff444444),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${state.companies[i].totalMembers} members',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff444444),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : CircularProgressIndicator()),
                ),
              Divider(
                thickness: 2.0,
                height: 2.0,
                color: Color(0xffEEEEEE),
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (ctx, state) => state is ProfileLoaded
                    ? Container(
                  height: 52,
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            ImageAvatar(
                              state.thumbnail,
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 15),
                            Text(
                              '${state.firstName} ${state.lastName}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff444444),
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () async {
                                await CookieManager().clearCookies();
                                BlocProvider.of<AuthBloc>(ctx)
                                    .add(ResetAuthentication());
                              },
                              child: Icon(
                                Icons.logout,
                                color: Color(0xff444444),
                                size: 30,
                              ),
                            ),
                          ],
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

// BlocBuilder<ProfileBloc, ProfileState>(
//   builder: (ctx, state) => state is ProfileLoaded
//       ? ListTile(
//           contentPadding: padding,
//           leading: ImageAvatar(state.thumbnail),
//           title: Text(
//             '${state.firstName} ${state.lastName}',
//             style: Theme.of(context).textTheme.headline5,
//           ), // TODO configure the styles
//           trailing: IconButton(
//             onPressed: () async {
//               await CookieManager().clearCookies();
//               BlocProvider.of<AuthBloc>(ctx)
//                   .add(ResetAuthentication());
//             },
//             color: Colors.black87,
//             icon: Icon(
//               Icons.logout,
//               size: Dim.tm4(),
//             ),
//           ),
//         )
//       : CircularProgressIndicator(),
// ),
