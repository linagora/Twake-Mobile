import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/globals/globals.dart';
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
          decoration: BoxDecoration(
            // waiting for accurate colors in the upcoming design
            color: message.userId == Globals.instance.userId
                ? Colors.grey[350]
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 3,
              ),
              Text(
                '${reaction.name}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Text(
                '${reaction.count}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              /* reaction.count > 1
                          ? Text(
                              '${reaction.count}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          : Container(),*/
            ],
          ),
        ),
      ),
    );
  }
}
