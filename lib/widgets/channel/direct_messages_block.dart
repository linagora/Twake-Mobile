import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/direct.dart';
import 'package:twake_mobile/widgets/channel/direct_tile.dart';

class DirectMessagesBlock extends StatelessWidget {
  final List<Direct> directMessages;
  DirectMessagesBlock(this.directMessages);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Direct Messages',
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
        ...directMessages.map((d) => DirectTile(d)).toList(),
      ],
    );
  }
}
