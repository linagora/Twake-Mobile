import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/repositories/messages_repository.dart';

class EmojiLine extends StatelessWidget {
  final Function(String emojiCode) onEmojiSelected;
  final Message message;

  EmojiLine({required this.message, required this.onEmojiSelected});

  static const EMOJISET = [
    '😅',
    '😂',
    '😇',
    '👍',
    '👌',
    '👋',
  ];

  static final fontSize = 44.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        color: Get.isDarkMode
            ? Theme.of(context).primaryColor.withOpacity(0.7)
            : Theme.of(context).cardColor,
      ),
      width: Dim.widthPercent(80),
      padding: EdgeInsets.symmetric(
        vertical: Dim.heightMultiplier,
        horizontal: 16.0, //Dim.wm2,
      ),
      constraints: BoxConstraints(maxHeight: Dim.hm10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...EmojiLine.EMOJISET.map((e) => Flexible(
                child: GestureDetector(
                  onTap: () {
                    onEmojiSelected(e);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      e,
                      style: TextStyle(fontSize: EmojiLine.fontSize),
                    ),
                  ),
                ),
              )),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                Get.find<MessageAnimationCubit>().openEmojiBoard(message);
              },
              iconSize: EmojiLine.fontSize + 3,
            ),
          ),
        ],
      ),
    );
  }
}
