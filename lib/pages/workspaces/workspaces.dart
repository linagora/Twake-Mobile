import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/companies_bloc/companies_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class Workspaces extends StatefulWidget {
  @override
  _WorkspacesState createState() => _WorkspacesState();
}

class _WorkspacesState extends State<Workspaces> {
  var _companiesHidden = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompaniesBloc, CompaniesState>(
      buildWhen: (_, current) => current is CompaniesLoaded,
      builder: (context, state) {
        var companies = <Company>[];
        Company selectedCompany;
        var canCreateWorkspace = false;

        if (state is CompaniesLoaded) {
          companies = state.companies;
          selectedCompany = state.selected;
          final permissions = selectedCompany.permissions;
          canCreateWorkspace = permissions.length > 0 &&
              permissions.contains('CREATE_WORKSPACES');
        }
        return BlocBuilder<WorkspacesBloc, WorkspaceState>(
          builder: (context, state) {
            Workspace selectedWorkspace;
            var workspaces = <Workspace>[];
            if (state is WorkspacesLoaded) {
              selectedWorkspace = state.selected;
              workspaces = state.workspaces;
            }
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 60.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _companiesHidden = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 19.0),
                            child: Icon(
                              Icons.loop,
                              color: Color(0xff444444),
                            ),
                          ),
                        ),
                        Text(
                          'Workspaces',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            BlocProvider.of<SheetBloc>(context)
                                .add(CloseSheet());
                          },
                          child: Container(
                            width: 48.0,
                            height: 48.0,
                            padding: EdgeInsets.only(right: 19.0),
                            child: Image.asset('assets/images/cancel.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: Color(0xfff4f4f4),
                  ),
                  if (_companiesHidden)
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: canCreateWorkspace
                            ? workspaces.length + 1
                            : workspaces.length,
                        itemBuilder: (context, index) {
                          if (index == 0 && canCreateWorkspace) {
                            return AddWorkspaceTile();
                          } else {
                            final workspace = canCreateWorkspace
                                ? workspaces[index - 1]
                                : workspaces[index];
                            return WorkspaceTile(
                              title: workspace.name,
                              image: workspace.logo,
                              selected: workspace.id == selectedWorkspace.id,
                              onTap: () {
                                BlocProvider.of<WorkspacesBloc>(context).add(
                                  ChangeSelectedWorkspace(workspace.id),
                                );
                                BlocProvider.of<ProfileBloc>(context).add(
                                  UpdateBadges(),
                                );
                                BlocProvider.of<SheetBloc>(context).add(
                                  CloseSheet(),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  if (!_companiesHidden)
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        itemCount: companies.length,
                        itemBuilder: (ctx, i) => InkWell(
                          onTap: () {
                            BlocProvider.of<CompaniesBloc>(context)
                                .add(ChangeSelectedCompany(companies[i].id));
                            BlocProvider.of<ProfileBloc>(context)
                                .add(UpdateBadges());
                            setState(() {
                              _companiesHidden = true;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ImageAvatar(
                                companies[i].logo,
                                width: 30,
                                height: 30,
                              ),
                              SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12),
                                  Text(
                                    companies[i].name,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff444444),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (companies[i].totalMembers != null)
                                    Text(
                                      '${companies[i].totalMembers} members',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff444444),
                                      ),
                                    ),
                                  SizedBox(height: 12),
                                ],
                              ),
                              Spacer(),
                              BlocBuilder<ProfileBloc, ProfileState>(
                                buildWhen: (_, current) =>
                                    current is ProfileLoaded,
                                builder: (context, state) {
                                  if (state is ProfileLoaded) {
                                    final count = state
                                        .getBadgeForCompany(companies[i].id);
                                    if (count > 0) {
                                      return Badge(
                                        shape: BadgeShape.square,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        badgeContent: Text(
                                          '$count',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return SizedBox();
                                    }
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AddWorkspaceTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SheetBloc>()
          ..add(SetFlow(flow: SheetFlow.addWorkspace))
          ..add(OpenSheet());
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: 8.0),
            Row(
              children: [
                SizedBox(width: 16.0),
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xfff5f5f5),
                  ),
                  child: Image.asset('assets/images/add.png'),
                ),
                SizedBox(width: 16.0),
                Text(
                  'Create a new workspace',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(
              thickness: 1.0,
              height: 1.0,
              color: Color(0xfff4f4f4),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkspaceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool selected;
  final Function onTap;

  const WorkspaceTile({
    Key key,
    this.title,
    this.subtitle,
    this.image,
    this.selected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: 8.0),
            Row(
              children: [
                SizedBox(width: 16.0),
                RoundedImage(
                  image,
                  width: 60.0,
                  height: 60.0,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff949494),
                          ),
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: Color(0xff3840F7),
                  ),
                SizedBox(width: 19.0),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(
              thickness: 1.0,
              height: 1.0,
              color: Color(0xfff4f4f4),
            ),
          ],
        ),
      ),
    );
  }
}
