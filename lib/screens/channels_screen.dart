import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/widgets/channel/channels_block.dart';
import 'package:twake_mobile/widgets/channel/direct_messages_block.dart';
// import 'package:twake_mobile/widgets/channel/starred_channels_block.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/drawer/twake_drawer.dart';

class ChannelsScreen extends StatelessWidget {
  static const String route = '/channels';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    print('DEBUG: building channels screen');
    final workspace = Provider.of<ProfileProvider>(context).selectedWorkspace;
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    channels.loadChannels(api, workspace.id);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: TwakeDrawer(),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
            icon: Icon(
              Icons.menu,
              size: Dim.tm4(),
            ),
          ),
          toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15)
              .round()), // taking into account current appBar height to calculate a new one
          actions: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: Dim.tm4(),
              ),
              onSelected: (choice) {},
              itemBuilder: (BuildContext context) {
                return {'Option 1', 'Option 2'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: [
                        Icon(Icons.star_outline),
                        SizedBox(width: Dim.wm2),
                        Text(choice),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
          title: Row(
            children: [
              ImageAvatar(workspace.logo),
              SizedBox(width: Dim.wm2),
              Text(workspace.name,
                  style: Theme.of(context).textTheme.headline6),
            ],
          ),
        ),
        body: Consumer<ChannelsProvider>(
          builder: (ctx, channels, _) {
            final items = channels.items;
            return channels.loaded
                ? SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dim.wm3,
                        vertical: Dim.heightMultiplier,
                      ),
                      child: Column(
                        children: [
                          // Starred channels will be implemented in version 2
                          // StarredChannelsBlock([]),
                          // Divider(height: Dim.hm5),
                          ChannelsBlock(items),
                          Divider(height: Dim.hm5),
                          DirectMessagesBlock([]),
                        ],
                      ),
                    ),
                  )
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
