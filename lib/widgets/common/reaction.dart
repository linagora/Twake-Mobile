import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/reaction.dart' as rct;
import 'package:twake/utils/emojis.dart';

class Reaction<T extends BaseMessagesCubit> extends StatelessWidget {
  final Message message;
  final rct.Reaction reaction;

  Reaction({required this.message, required this.reaction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<ChannelMessagesCubit>()
            .react(message: message, reaction: reaction.name);
      },
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 3, left: 2, right: 2),
          child: Container(
            decoration: BoxDecoration(
              // waiting for accurate colors in the upcoming design
              color: Get.isDarkMode
                  ? message.isOwnerMessage
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.2)
                      : Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.12)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.12),

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
                    width: 4,
                  ),
                  Text(
                    '${reaction.count}',
                    style: Get.isDarkMode
                        ? message.isOwnerMessage
                            ? Theme.of(context).textTheme.headline1!.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 12)
                            : Theme.of(context).textTheme.headline1!.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 12)
                        : Theme.of(context).textTheme.headline4!.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 12),
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
