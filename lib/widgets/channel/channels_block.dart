import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/widgets/channel/channel_tile.dart';

class ChannelsBlock extends StatelessWidget {
  final List<Channel> channels;
  ChannelsBlock(this.channels);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Channels',
              style: Theme.of(context).textTheme.headline3,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {},
                  iconSize: Dim.tm4(),
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        ...channels.map((c) => ChannelTile(c)).toList(),
      ],
    );
  }
}
