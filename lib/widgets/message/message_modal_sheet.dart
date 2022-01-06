import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/message/message.dart';

class MessageModalSheet<T extends BaseMessagesCubit> extends StatefulWidget {
  final Message message;
  final void Function(Message)? onReply;
  final void Function()? onDelete;
  final Function? onEdit;
  final Function? onCopy;
  final BuildContext? ctx;
  final bool isMe;
  final bool isThread;

  const MessageModalSheet({
    required this.message,
    this.onReply,
    this.onDelete,
    this.onEdit,
    this.onCopy,
    this.ctx,
    required this.isMe,
    this.isThread = false,
    Key? key,
  }) : super(key: key);

  @override
  _MessageModalSheetState createState() => _MessageModalSheetState<T>();
}

class _MessageModalSheetState<T extends BaseMessagesCubit>
    extends State<MessageModalSheet> {
  bool _emojiVisible = false;

  onEmojiSelected(String emojiCode, {bool popOut = false}) {
    Get.find<T>().react(message: widget.message, reaction: emojiCode);
    Future.delayed(
      Duration(milliseconds: 50),
      FocusManager.instance.primaryFocus?.unfocus,
    );
    if (popOut) {
      Navigator.pop(context);
    }
  }

  void toggleEmojiBoard() async {
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }

  Widget buildEmojiBoard() {
    return Container(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (cat, emoji) {
          toggleEmojiBoard();
          onEmojiSelected(emoji.emoji, popOut: true);
        },
        config: Config(
          columns: 7,
          emojiSizeMax: 32.0,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: Theme.of(context).colorScheme.secondaryVariant,
          indicatorColor: Theme.of(context).colorScheme.surface,
          iconColor: Theme.of(context).colorScheme.secondary,
          iconColorSelected: Theme.of(context).colorScheme.surface,
          progressIndicatorColor: Theme.of(context).colorScheme.surface,
          showRecentsTab: true,
          recentsLimit: 28,
          noRecentsText: AppLocalizations.of(context)!.noRecents,
          noRecentsStyle:
              Theme.of(context).textTheme.headline3!.copyWith(fontSize: 20),
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _emojiVisible
        ? buildEmojiBoard()
        : Container(
            height: Dim.heightPercent(45),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  child: EmojiLine(
                    onEmojiSelected: onEmojiSelected,
                    showEmojiBoard: toggleEmojiBoard,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isMe && widget.message.responsesCount == 0)
                            GestureDetector(
                              child: Column(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(AppLocalizations.of(context)!.delete,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500))
                                ],
                              ),
                              onTap: () {
                                widget.onDelete!();
                              },
                            ),
                          if (widget.isMe && widget.message.responsesCount == 0)
                            Flexible(
                              child: SizedBox(
                                width: 30,
                              ),
                            ),
                          widget.message.blocks.isEmpty
                              ? Container()
                              : GestureDetector(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 55,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.copy_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.copy,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    widget.onCopy!();
                                  },
                                ),
                          if (!widget.message.inThread &&
                              !widget.isThread &&
                              widget.message.blocks.isNotEmpty)
                            Flexible(
                              child: SizedBox(
                                width: 30,
                              ),
                            ),
                          if (!widget.message.inThread && !widget.isThread)
                            GestureDetector(
                              child: Column(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.reply_sharp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.reply,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onReply!(widget.message);
                              },
                            ),
                          if (widget.isMe)
                            Flexible(
                              child: SizedBox(
                                width: 30,
                              ),
                            ),
                          if (widget.isMe)
                            GestureDetector(
                              child: Column(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.edit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                              onTap: widget.onEdit as void Function()?,
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

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
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
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
