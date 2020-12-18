import 'package:flutter/material.dart';
import 'package:twake_mobile/models/workspace.dart';
import 'package:twake_mobile/screens/channels_screen.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';

class WorkspaceTile extends StatelessWidget {
  final Workspace workspace;
  WorkspaceTile(this.workspace);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ChannelsScreen.route, arguments: workspace.id);
      },
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: ImageAvatar(workspace.logo),
          title: Text(
            workspace.name,
            style: Theme.of(context).textTheme.headline3,
          ),
          subtitle: Text(
            '7 channels',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          trailing: Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
