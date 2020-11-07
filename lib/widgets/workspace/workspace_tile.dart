import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/workspace.dart';
import 'package:mime/mime.dart';
import 'package:twake_mobile/screens/channels_screen.dart';

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
          leading: CircleAvatar(
            radius: 5 * DimensionsConfig.widthMultiplier,
            backgroundImage: workspace.logo.isNotEmpty
                ? NetworkImage(
                    workspace.logo,
                    headers: {
                      'Content-Type':
                          lookupMimeType(workspace.logo.split('/').last),
                      'Accept':
                          'image/jpg, image/png, image/jpeg, application/octet-stream'
                    },
                  )
                : AssetImage('assets/images/empty-image.png'),
          ),
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
