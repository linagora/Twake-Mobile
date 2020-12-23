import 'package:flutter/material.dart';
import 'package:twake/widgets/channel/direct_tile.dart';

class DirectMessagesGroup extends StatelessWidget {
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
            // Expanded(
            // child: Align(
            // alignment: Alignment.centerRight,
            // child: IconButton(
            // onPressed: () {},
            // iconSize: Dim.tm4(),
            // icon: Icon(
            // Icons.add,
            // color: Colors.black,
            // ),
            // ),
            // ),
            // ),
          ],
        ),
        ...[].map((d) => DirectTile(d)).toList(),
      ],
    );
  }
}
