import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/reaction.dart' as rct;
import 'package:twake/utils/emojis.dart';

class Reaction<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final rct.Reaction reaction;

  Reaction({
    required this.message,
    required this.reaction,
  });

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
              color: Theme.of(context).colorScheme.surface.withOpacity(0.12),

              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
              child: Row(
                children: [
                  Text(
                    '${Emojis.getByName(reaction.name)}',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline3!.color),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    '${reaction.count}',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  SizedBox(
                    width: 3,
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
