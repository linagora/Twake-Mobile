import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/utils/emojis.dart';

class Reaction extends StatelessWidget {
  final String reaction;
  final int count;
  Reaction(this.reaction, this.count);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: FittedBox(
        child: Container(
          // constraints: BoxConstraints(
          // minWidth: Dim.widthPercent(10),
          // maxWidth: Dim.widthPercent(13),
          // ),
          margin: EdgeInsets.only(right: Dim.wm2),
          padding: EdgeInsets.all(Dim.widthMultiplier),
          decoration: BoxDecoration(
            color: Color.fromRGBO(249, 247, 255, 1),
            border: Border.all(color: StylesConfig.accentColorRGB),
            borderRadius: BorderRadius.circular(Dim.widthMultiplier / 2),
          ),
          child: Align(
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(text: Emojis().getByName(reaction)),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: '$count',
                    style: StylesConfig.miniPurple,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
