import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/widgets/common/image_avatar.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';

class Workspaces extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    Container(
                      width: 48.0,
                      padding: EdgeInsets.only(right: 19.0),
                    ),
                    Text(
                      'Workspaces',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      width: 48.0,
                      height: 48.0,
                      padding: EdgeInsets.only(right: 19.0),
                      child: Image.asset('assets/images/cancel.png'),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.0, thickness: 1.0, color: Color(0xfff4f4f4)),
              Container(
                height: MediaQuery.of(context).size.height * 0.5 - 106.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: workspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaces[index];
                    return WorkspaceTile(
                      title: workspace.name,
                      image: workspace.logo,
                      selected: workspace.id == selectedWorkspace.id,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WorkspaceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool selected;

  const WorkspaceTile({
    Key key,
    this.title,
    this.subtitle,
    this.image,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 76.0,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 16.0),
              ImageAvatar(
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
          Divider(
            thickness: 1.0,
            height: 1.0,
            color: Color(0xfff4f4f4),
          ),
        ],
      ),
    );
  }
}
