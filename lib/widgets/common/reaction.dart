import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/single_message_bloc.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/styles_config.dart';

class Reaction extends StatelessWidget {
  final String reaction;
  final int count;
  Reaction(this.reaction, this.count);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BlocProvider.of<SingleMessageBloc>(context).add(
          UpdateReaction(emojiCode: reaction),
        );
      },
      child: FittedBox(
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
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(text: reaction),
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
