import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class EmojiLine extends StatelessWidget {
  final Function? onEmojiSelected;
  final Function? showEmojiBoard;

  EmojiLine({this.onEmojiSelected, this.showEmojiBoard});

  static const EMOJISET = [
    '😅',
    '😂',
    '😇',
    '👍',
    '👌',
    '👋',
  ];

  @override
  Widget build(BuildContext context) {
    final fontSize = 27.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Get.isDarkMode
            ? Theme.of(context).primaryColor.withOpacity(0.7)
            : Theme.of(context).cardColor,
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
          ...EMOJISET.map((e) => Flexible(
                child: GestureDetector(
                  onTap: () {
                    onEmojiSelected!(e);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: FittedBox(
                      child: Text(
                        e,
                        style: TextStyle(fontSize: fontSize),
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
              onPressed: showEmojiBoard as void Function()?,
              iconSize: fontSize + 3,
            ),
          ),
        ],
      ),
    );
  }
}
