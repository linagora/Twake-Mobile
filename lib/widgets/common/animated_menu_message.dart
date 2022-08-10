import 'dart:ui';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/widgets/message/emoji_set.dart';

class MenuMessageDropDown<T extends BaseMessagesCubit> extends StatefulWidget {
  final ItemPositionsListener itemPositionsListener;
  final Size? messagesListSize;
  final Offset? messageListPosition;
  final int clickedItem;
  final bool isReverse;
  final Function? onReply;
  final Function? onDelete;
  final Function? onEdit;
  final Function? onCopy;
  final Function? onPinMessage;
  final Function? onUnpinMessage;
  final Message message;

  const MenuMessageDropDown({
    key,
    required this.message,
    required this.itemPositionsListener,
    required this.clickedItem,
    this.messagesListSize,
    this.messageListPosition,
    this.isReverse = true,
    this.onReply,
    this.onDelete,
    this.onEdit,
    this.onCopy,
    this.onPinMessage,
    this.onUnpinMessage,
  }) : super(key: key);

  @override
  State<MenuMessageDropDown> createState() => _MenuMessageDropDownState<T>();
}

class _MenuMessageDropDownState<T extends BaseMessagesCubit>
    extends State<MenuMessageDropDown> {
  AnimationConfig begin = AnimationConfig();
  late AnimationConfig end;

  int clickedItem = -1;

  bool _emojiVisible = false;

  int numberOfDropDownBar = 0;
  List<dynamic> dropdownFuncs = [];

  @override
  void initState() {
    super.initState();
    clickedItem = widget.clickedItem;

    dropdownFuncs = [
      widget.onReply,
      widget.onCopy,
      widget.onEdit,
      widget.onDelete,
      widget.onPinMessage,
      widget.onUnpinMessage
    ];
    numberOfDropDownBar =
        dropdownFuncs.where((element) => element != null).length;
  }

  void didUpdateWidget(covariant MenuMessageDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    clickedItem = widget.clickedItem;
  }

  @override
  Widget build(BuildContext context) {
    Curve curveAnimation = Curves.fastOutSlowIn;
    Duration durationAnimation = const Duration(milliseconds: 300);

    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: widget.itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        double? itemLeadingEdge;
        double? itemTrailingEdge;

        if (positions.isEmpty) {
          return Column();
        }

        // if don't find clicked index of item
        Iterable<ItemPosition> clickedPositions =
            positions.where((element) => element.index == clickedItem);
        if (clickedPositions.isEmpty) {
          return Column();
        }
        itemLeadingEdge = clickedPositions.first.itemLeadingEdge;
        itemTrailingEdge = clickedPositions.first.itemTrailingEdge;

        if (widget.isReverse) {
          var tmp = itemLeadingEdge;
          itemLeadingEdge = 1 - itemTrailingEdge;
          itemTrailingEdge = 1 - tmp;
        }

        double emojiHeight = 50;
        double dropMenuHeight = (DropDownButton.DROPDOWN_HEIGHT +
                DropDownButton.DROPDOWN_PADDING * 2 +
                DropDownButton.DROPDOWN_SEPARATOR_HEIGHT) *
            numberOfDropDownBar.toDouble();
        double messageListHeight = widget.messagesListSize!.height;

        double topLeftListY = 0;
        if (widget.messageListPosition != null) {
          topLeftListY = widget.messageListPosition!.dy;
        }

        // calculate size of item
        double itemHeight =
            (itemTrailingEdge - itemLeadingEdge) * messageListHeight;
        double middleItemY =
            itemHeight / 2 + topLeftListY + itemLeadingEdge * messageListHeight;
        double itemHeightMax = screenHeight - emojiHeight - dropMenuHeight;
        double totalHeight = itemHeight + emojiHeight + dropMenuHeight;
        double left = 0;
        double topOfComponents =
            itemLeadingEdge * messageListHeight + topLeftListY - emojiHeight;

        double itemScale = 1;
        double itemTranslateY = 0;

        if (itemHeight > itemHeightMax) {
          itemScale = itemHeightMax / itemHeight;
          itemTranslateY = (emojiHeight + itemHeightMax / 2) - middleItemY;
          topOfComponents -= emojiHeight;
        } else {
          if (itemLeadingEdge * messageListHeight + topLeftListY <
              emojiHeight) {
            itemTranslateY = emojiHeight -
                itemLeadingEdge * messageListHeight -
                topLeftListY;
          } else if (itemTrailingEdge * messageListHeight + topLeftListY >
              screenHeight - dropMenuHeight) {
            itemTranslateY = screenHeight -
                dropMenuHeight -
                itemTrailingEdge * messageListHeight -
                topLeftListY;
          }
        }
        // set how animation should end
        end = AnimationConfig(
            isBlur: 10, translateY: itemTranslateY, scaleFactor: itemScale);
        return IgnorePointer(
            ignoring: false,
            child: TweenAnimationBuilder<AnimationConfig>(
              duration: durationAnimation,
              tween: Tween<AnimationConfig>(
                begin: begin,
                end: end,
              ),
              curve: curveAnimation,
              builder: (context, animationConfig, __) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.find<MessageAnimationCubit>().endAnimation();
                      },
                      child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: animationConfig.isBlur,
                            sigmaY: animationConfig.isBlur,
                          ),
                          child: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            color: Colors.transparent,
                          )),
                    ),
                    Positioned(
                      width: screenWidth,
                      left: left,
                      height: totalHeight,
                      top: topOfComponents,
                      child: GestureDetector(
                        onTap: () =>
                            Get.find<MessageAnimationCubit>().endAnimation(),
                        child: _buildAnimatedMessage(
                          isOwnerMessage: widget.message.isOwnerMessage,
                          curve: curveAnimation,
                          itemTranslateY: itemTranslateY,
                          itemScale: itemScale,
                          duration: durationAnimation,
                          child: Column(
                            children: [
                              Transform.scale(
                                  scale:
                                      animationConfig.scaleDropDown / itemScale,
                                  alignment: Alignment.bottomLeft,
                                  child: EmojiLine(
                                    onEmojiSelected: onEmojiSelected,
                                    showEmojiBoard: toggleEmojiBoard,
                                  )),
                              MessageTile<T>(message: widget.message),
                              Transform.scale(
                                alignment: Alignment.topLeft,
                                scale:
                                    animationConfig.scaleDropDown / itemScale,
                                child: Column(
                                  children: [
                                    if (widget.onReply != null) ...[
                                      DropDownButton(
                                        text:
                                            AppLocalizations.of(context)!.reply,
                                        icon: Icons.reply_outlined,
                                        isTop: true,
                                        onClick: () => widget.onReply!(),
                                      )
                                    ],
                                    if (widget.onEdit != null) ...[
                                      DropDownButton(
                                        text:
                                            AppLocalizations.of(context)!.edit,
                                        icon: Icons.edit_outlined,
                                        onClick: () => widget.onEdit!(),
                                      )
                                    ],
                                    if (widget.onCopy != null) ...[
                                      DropDownButton(
                                        text:
                                            AppLocalizations.of(context)!.copy,
                                        icon: Icons.copy_outlined,
                                        onClick: () => widget.onCopy!(),
                                      )
                                    ],
                                    if (widget.onPinMessage != null) ...[
                                      DropDownButton(
                                        text: AppLocalizations.of(context)!
                                            .pinMesssage,
                                        icon: Icons.push_pin_outlined,
                                        onClick: () => widget.onPinMessage!(),
                                      )
                                    ],
                                    if (widget.onUnpinMessage != null) ...[
                                      DropDownButton(
                                        text: AppLocalizations.of(context)!
                                            .unpinMesssage,
                                        isSecondBottom: true,
                                        onClick: () => widget.onUnpinMessage!(),
                                      )
                                    ],
                                    if (widget.onDelete != null) ...[
                                      DropDownButton(
                                        isBottom: true,
                                        text: AppLocalizations.of(context)!
                                            .delete,
                                        icon: Icons.delete_outline,
                                        textColor: Colors.red,
                                        iconColor: Colors.red,
                                        onClick: () => widget.onDelete!(),
                                      )
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_emojiVisible) ...[
                      buildEmojiBoard(),
                    ]
                  ],
                );
              },
            ));
      },
    );
  }

  Widget _buildAnimatedMessage(
      {double itemTranslateY = 0,
      double itemScale = 1,
      required Duration duration,
      required Widget child,
      curve = Curves.linear,
      isOwnerMessage = false}) {
    return TweenAnimationBuilder<AnimationConfig>(
        curve: curve,
        tween: Tween<AnimationConfig>(
            begin: AnimationConfig(),
            end: AnimationConfig(
                scaleFactor: itemScale, translateY: itemTranslateY)),
        duration: duration,
        builder: ((context, value, _) {
          if (value.translateY == 0 && value.scaleFactor == 1) {
            return child;
          }
          return Transform.translate(
            offset: Offset(0, value.translateY),
            child: Transform.scale(
              alignment:
                  isOwnerMessage ? Alignment.centerRight : Alignment.centerLeft,
              scale: value.scaleFactor,
              child: child,
            ),
          );
        }));
  }

  Widget buildEmojiBoard() {
    return Container(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (cat, emoji) {
          toggleEmojiBoard();
          onEmojiSelected(emoji.emoji);
        },
        config: Config(
          columns: 7,
          emojiSizeMax: 32.0,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: Theme.of(context).colorScheme.secondaryContainer,
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

  onEmojiSelected(String emojiCode, {bool popOut = false}) async {
    if (widget.message.inThread) {
      await Get.find<ThreadMessagesCubit>()
          .react(message: widget.message, reaction: emojiCode);
    } else {
      await Get.find<ChannelMessagesCubit>()
          .react(message: widget.message, reaction: emojiCode);
    }
    Future.delayed(
      Duration(milliseconds: 50),
      FocusManager.instance.primaryFocus?.unfocus,
    );

    Get.find<MessageAnimationCubit>().endAnimation();
  }

  void toggleEmojiBoard() async {
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }
}

class DropDownButton extends StatelessWidget {
  final bool isTop;
  final bool isBottom;
  final bool isSecondBottom;
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Function() onClick;

  static const double DROPDOWN_WIDTH = 254;
  static const double DROPDOWN_HEIGHT = 44;
  static const double DROPDOWN_PADDING = 5;
  static const double DROPDOWN_TOP_LAST_ITEM_PADDING_HEIGHT = 8;
  static const double DROPDOWN_SEPARATOR_HEIGHT = 1;

  const DropDownButton({
    required this.onClick,
    required this.text,
    this.isBottom = false,
    this.isTop = false,
    this.isSecondBottom = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (isBottom) ...[
        Container(
          height: DROPDOWN_TOP_LAST_ITEM_PADDING_HEIGHT,
          width: DropDownButton.DROPDOWN_WIDTH,
          color: Color(0x14141426),
        )
      ],
      GestureDetector(
        onTap: () => onClick(),
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: isTop
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0))
                  : (isBottom
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))
                      : null)),
          width: DROPDOWN_WIDTH,
          height: DROPDOWN_HEIGHT,
          padding: const EdgeInsets.all(DROPDOWN_PADDING),
          child: Row(children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(color: textColor),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Icon(icon, color: iconColor)],
            ),
          ]),
        ),
      ),
      Container(
          color: isBottom || isSecondBottom ? null : Colors.black,
          height: DROPDOWN_SEPARATOR_HEIGHT,
          width: DROPDOWN_WIDTH),
    ]);
  }
}

class AnimationConfig extends Object {
  double isBlur;
  double translateY;
  double scaleFactor;
  double scaleDropDown;

  AnimationConfig(
      {this.isBlur = 10,
      this.translateY = 0,
      this.scaleFactor = 1,
      this.scaleDropDown = 1});

  AnimationConfig operator +(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          isBlur: isBlur + other.isBlur,
          scaleFactor: scaleFactor + other.scaleFactor,
          translateY: translateY + other.translateY,
          scaleDropDown: scaleDropDown + other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          isBlur: isBlur + other,
          scaleFactor: scaleFactor + other,
          translateY: translateY + other,
          scaleDropDown: scaleDropDown + other);
    }
    throw UnsupportedError("unsupport operation");
  }

  AnimationConfig operator -(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          isBlur: isBlur - other.isBlur,
          scaleFactor: scaleFactor - other.scaleFactor,
          translateY: translateY - other.translateY,
          scaleDropDown: scaleDropDown - other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          isBlur: isBlur - other,
          scaleFactor: scaleFactor - other,
          translateY: translateY - other,
          scaleDropDown: scaleDropDown - other);
    }
    throw UnsupportedError("unsupport operation");
  }

  AnimationConfig operator *(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          isBlur: isBlur * other.isBlur,
          scaleFactor: scaleFactor * other.scaleFactor,
          translateY: translateY * other.translateY,
          scaleDropDown: scaleDropDown * other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          isBlur: isBlur * other,
          scaleFactor: scaleFactor * other,
          translateY: translateY * other,
          scaleDropDown: scaleDropDown * other);
    }
    throw UnsupportedError("unsupport operation");
  }

  AnimationConfig operator /(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          isBlur: isBlur / other.isBlur,
          scaleFactor: scaleFactor / other.scaleFactor,
          translateY: translateY / other.translateY,
          scaleDropDown: scaleDropDown / other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          isBlur: isBlur / other,
          scaleFactor: scaleFactor / other,
          translateY: translateY / other,
          scaleDropDown: scaleDropDown / other);
    }
    throw UnsupportedError("unsupport operation");
  }

  @override
  bool operator ==(Object other) {
    if (other is AnimationConfig) {
      return isBlur == other.isBlur &&
          scaleFactor == other.scaleFactor &&
          translateY == other.translateY &&
          scaleDropDown == other.scaleDropDown;
    }
    throw UnsupportedError("unsupport operation");
  }

  @override
  int get hashCode =>
      isBlur.hashCode +
      scaleFactor.hashCode +
      translateY.hashCode +
      scaleDropDown.hashCode;
}
