import 'package:flutter/material.dart';
import 'package:twake/services/init.dart';
import 'package:twake/widgets/common/twake_drawer.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/image_avatar.dart';

class MainPage extends StatefulWidget {
  static const route = '/main';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  InitData data;
  @override
  void initState() async {
    super.initState();
    data = await initMain();
  }

  @override
  Widget build(BuildContext context) {
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
          toolbarHeight: Dim.heightPercent(
            (kToolbarHeight * 0.15).round(),
          ), // taking into account current appBar height to calculate a new one
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
