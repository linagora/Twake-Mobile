import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/widgets/channel/channel_tile.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/drawer/twake_drawer.dart';

class ChannelsScreen extends StatelessWidget {
  static const String route = '/channels';
  @override
  Widget build(BuildContext context) {
    print('DEBUG: building channels screen');
    final workspace = Provider.of<ProfileProvider>(context).selectedWorkspace;
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    channels.loadChannels(api, workspace.id);
    return SafeArea(
      child: Scaffold(
        drawer: TwakeDrawer(),
        appBar: AppBar(
          actions: [
            PopupMenuButton<String>(
              onSelected: (choice) {},
              itemBuilder: (BuildContext context) {
                return {'Star channel', 'Unstar channel'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          shadowColor: Colors.grey[300],
          title: Row(
            children: [
              ImageAvatar(workspace.logo),
              SizedBox(width: DimensionsConfig.widthMultiplier * 2),
              Text(workspace.name),
            ],
          ),
        ),
        body: Consumer<ChannelsProvider>(
          builder: (ctx, channels, _) {
            final items = channels.items;
            return channels.loaded
                ? ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      return ChannelTile(items[i]);
                    },
                  )
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
