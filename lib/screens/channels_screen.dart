import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/widgets/channel/channel_tile.dart';
import 'package:twake_mobile/widgets/drawer/twake_drawer.dart';

class ChannelsScreen extends StatelessWidget {
  static const String route = '/channels';
  @override
  Widget build(BuildContext context) {
    print('DEBUG: building channels screen');
    final workspaceId =
        Provider.of<ProfileProvider>(context, listen: false).firstWorkspaceId;
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        drawer: TwakeDrawer(),
        appBar: AppBar(
          title: Text('Workspace channels'),
        ),
        body: FutureBuilder(
          future: channels.loadChannels(api, workspaceId),
          builder: (ctx, snapshot) {
            final items =
                Provider.of<ChannelsProvider>(context, listen: false).items;
            return snapshot.connectionState == ConnectionState.done
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
