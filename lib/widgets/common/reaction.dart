import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/reaction.dart' as rct;

class Reaction<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final rct.Reaction reaction;
  Reaction({required this.message, required this.reaction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<T>().react(message: message, reaction: reaction.name);
      },
      child: FittedBox(
        child: Container(
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Color.fromRGBO(249, 247, 255, 1),
            border: Border.all(color: StylesConfig.accentColorRGB),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(text: reaction.name),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: '${reaction.count}',
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
