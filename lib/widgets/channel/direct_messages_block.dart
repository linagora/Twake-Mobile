import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/channel.dart';
import 'package:twake_mobile/widgets/channel/channel_tile.dart';

class DirectMessagesBlock extends StatelessWidget {
  final List<Channel> directMessages;
  DirectMessagesBlock(this.directMessages);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Direct Messages',
              style: Theme.of(context).textTheme.headline6,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {},
                  iconSize:
                      DimensionsConfig.textMultiplier * ICON_SIZE_MULTIPLIER,
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        ...directMessages.map((c) => ChannelTile(c)).toList(),
      ],
    );
  }
}
