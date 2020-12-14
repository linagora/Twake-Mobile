import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/utils/notifications_handler.dart';
import 'package:twake_mobile/widgets/channel/channels_block.dart';
import 'package:twake_mobile/widgets/channel/direct_messages_block.dart';
// import 'package:twake_mobile/widgets/channel/starred_channels_block.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
import 'package:twake_mobile/widgets/drawer/twake_drawer.dart';

class ChannelsScreen extends StatefulWidget {
  static const String route = '/channels';

  @override
  _ChannelsScreenState createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var notificationsHandler;

  @override
  void initState() {
    super.initState();
    notificationsHandler = NotificationsHandler(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final workspace = profile.selectedWorkspace;
    final company = profile.selectedCompany;
    final api = Provider.of<TwakeApi>(context, listen: false);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: TwakeDrawer(),
        appBar: AppBar(
          titleSpacing: 0.0,
          leading: IconButton(
            padding: EdgeInsets.only(left: Dim.wm3),
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
              padding: EdgeInsets.only(right: Dim.wm3),
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
        body: FutureBuilder(
          future:
              channels.loadChannels(api, workspace.id, companyId: company.id),
          builder: (ctx, spapshot) =>
              spapshot.connectionState == ConnectionState.done
                  ? RefreshIndicator(
                      onRefresh: () {
                        return channels.loadChannels(api, workspace.id,
                            companyId: company.id);
                      },
                      child: Consumer<ChannelsProvider>(
                        builder: (ctx, channels, _) {
                          final items = channels.items;
                          final directs = channels.directs;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dim.wm3,
                              vertical: Dim.heightMultiplier,
                            ),
                            child: ListView(
                              children: [
                                // Starred channels will be implemented in version 2
                                // StarredChannelsBlock([]),
                                // Divider(height: Dim.hm5),
                                ChannelsBlock(items),
                                Divider(height: Dim.hm5),
                                DirectMessagesBlock(directs),
                                SizedBox(height: Dim.hm2),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
