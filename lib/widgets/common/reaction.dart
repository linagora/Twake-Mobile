import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/utils/emojis.dart';

class Reaction extends StatelessWidget {
  final String reaction;
  final int count;
  Reaction(this.reaction, this.count);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: Dim.wm2),
      padding: EdgeInsets.all(Dim.widthMultiplier),
      decoration: BoxDecoration(
        color: Color.fromRGBO(249, 247, 255, 1),
        border: Border.all(color: StylesConfig.accentColorRGB),
        borderRadius: BorderRadius.circular(Dim.widthMultiplier / 2),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(Emojis.getClosestMatch(reaction)),
            SizedBox(width: Dim.widthMultiplier),
            Text(
              '$count',
              style: StylesConfig.miniPurple,
            ),
          ],
        ),
      ),
    );
  }
}
