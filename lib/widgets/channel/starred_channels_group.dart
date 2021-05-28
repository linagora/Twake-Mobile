/* import 'package:flutter/material.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/widgets/channel/channel_tile.dart';

class StarredChannelsBlock extends StatelessWidget {
  final List<Channel> starred;
  StarredChannelsBlock(this.starred);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Starred Channels',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        if (starred.length > 0) ...starred.map((c) => ChannelTile(c)).toList()
      ],
    );
  }
}
 */
