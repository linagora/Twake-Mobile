import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/utils/emojis.dart';

class Reaction extends StatefulWidget {
  final String reaction;
  final int count;
  Reaction(this.reaction, this.count);

  @override
  _ReactionState createState() => _ReactionState();
}

class _ReactionState extends State<Reaction> {
  @override
  Widget build(BuildContext context) {
    TwakeApi api = Provider.of<TwakeApi>(context, listen: false);
    return InkWell(
      onTap: () {
        Provider.of<Message>(context, listen: false).updateReactions(
          api: api,
          emojiCode: widget.reaction,
          userId: Provider.of<ProfileProvider>(context, listen: false)
              .currentProfile
              .userId,
        );
      },
      child: Container(
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
              Text(Emojis.getClosestMatch(widget.reaction)),
              SizedBox(width: Dim.widthMultiplier),
              Text(
                '${widget.count}',
                style: StylesConfig.miniPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
