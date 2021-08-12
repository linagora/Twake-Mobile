import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/reaction.dart' as rct;
import 'package:twake/utils/emojis.dart';

class Reaction<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final rct.Reaction reaction;
  final bool isFirstInThread;
  Reaction(
      {required this.message,
      required this.reaction,
      this.isFirstInThread = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<T>().react(message: message, reaction: reaction.name);
      },
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 3, left: 2, right: 2),
          child: Container(
            decoration: BoxDecoration(
              // waiting for accurate colors in the upcoming design
              color: Color(0xFFE8E8E8),
              border: Border.all(color: Color(0xFFE8E8E8), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
              child: Row(
                children: [
                  Text(
                    '${Emojis.getByName(reaction.name)}',
                    style: TextStyle(
                      fontSize: isFirstInThread ? 20 : 15,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF818C99),
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
        ),
      ),
    );
  }
}
