import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/repositories/messages_repository.dart';

class EmojiLine extends StatefulWidget {
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

  static final fontSize = 27.0;

  @override
  State<StatefulWidget> createState() => _EmojiLineState();
}

class _EmojiLineState extends State<EmojiLine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Theme.of(context).primaryColor,
      ),
      width: Dim.widthPercent(80),
      padding: EdgeInsets.symmetric(
        vertical: Dim.heightMultiplier,
        horizontal: 16.0, //Dim.wm2,
      ),
      constraints: BoxConstraints(maxHeight: Dim.hm7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...EmojiLine.EMOJISET.map((e) => Flexible(
                child: GestureDetector(
                  onTap: () {
                    widget.onEmojiSelected(e);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: FittedBox(
                      child: Text(
                        e,
                        style: TextStyle(fontSize: EmojiLine.fontSize),
                      ),
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
                Get.find<MessageAnimationCubit>().openEmojiBoard(widget.message);
              },
              iconSize: EmojiLine.fontSize + 3,
            ),
          ),
        ],
      ),
    );
  }
}
