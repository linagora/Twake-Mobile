import 'dart:ui';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/chat/message_tile.dart';

class MenuMessageDropDown<T extends BaseMessagesCubit> extends StatefulWidget {
  final ItemPositionsListener itemPositionsListener;
  final Size? messagesListSize;
  final Offset? messageListPosition;
  final int clickedItem;
  final bool isReverse;

  /// widget which is below message
  final Widget? lowerWidget;

  /// in order to long press animation work, it require the height of widget when it's not even build
  final double? lowerWidgetHeight;

  final Widget? upperWidget;

  final double? upperWidgetHeight;

  final Message message;

  const MenuMessageDropDown({
    key,
    required this.message,
    required this.itemPositionsListener,
    required this.clickedItem,
    this.lowerWidget,
    this.lowerWidgetHeight,
    this.upperWidget,
    this.upperWidgetHeight,
    this.messagesListSize,
    this.messageListPosition,
    this.isReverse = true,
  }) : super(key: key);

  @override
  State<MenuMessageDropDown> createState() => _MenuMessageDropDownState<T>();
}

class _MenuMessageDropDownState<T extends BaseMessagesCubit>
    extends State<MenuMessageDropDown> {
  AnimationConfig begin = AnimationConfig();
  late AnimationConfig end;

  int clickedItem = -1;

  late double screenHeight;
  late double screenWidth;

  @override
  void initState() {
    super.initState();
    clickedItem = widget.clickedItem;
  }

  void didUpdateWidget(covariant MenuMessageDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    clickedItem = widget.clickedItem;
  }

  @override
  void didChangeDependencies() {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Curve curveAnimation = Curves.fastOutSlowIn;
    Duration durationAnimation = const Duration(milliseconds: 300);
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: widget.itemPositionsListener.itemPositions,
      builder: (context, positions, child) {
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

        double upperWidgetHeight = widget.upperWidgetHeight ?? 0;
        double dropMenuHeight = widget.lowerWidgetHeight ?? 0;
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
        double itemHeightMax =
            screenHeight - upperWidgetHeight - dropMenuHeight;
        double totalHeight = itemHeight + upperWidgetHeight + dropMenuHeight;
        double left = 0;
        double topOfComponents = itemLeadingEdge * messageListHeight +
            topLeftListY -
            upperWidgetHeight;

        double itemScale = 1;
        double itemTranslateY = 0;

        if (itemHeight > itemHeightMax) {
          itemScale = itemHeightMax / itemHeight;
          itemTranslateY =
              (upperWidgetHeight + itemHeightMax / 2) - middleItemY;
          topOfComponents -= upperWidgetHeight;
        } else {
          if (itemLeadingEdge * messageListHeight + topLeftListY <
              upperWidgetHeight) {
            itemTranslateY = upperWidgetHeight -
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
            blurDegree: 10, translateY: itemTranslateY, scaleFactor: itemScale);
        return TweenAnimationBuilder<AnimationConfig>(
          duration: durationAnimation,
          tween: Tween<AnimationConfig>(
            begin: begin,
            end: end,
          ),
          curve: curveAnimation,
          builder: (context, animationConfig, __) {
            return SafeArea(
              // solution for hit test not working when child bigger than parent, use combine with DeferPointer
              child: DeferredPointerHandler(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Chat.of(context).endAnimation();
                      },
                      child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: animationConfig.blurDegree,
                            sigmaY: animationConfig.blurDegree,
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
                            Chat.of(context).endAnimation(),
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
                                alignment: widget.message.isOwnerMessage
                                    ? Alignment.bottomRight
                                    : Alignment.bottomLeft,
                                child: widget.upperWidget != null
                                    ? DeferPointer(child: widget.upperWidget!)
                                    : null,
                              ),
                              MessageTile<T>(message: widget.message),
                              Transform.scale(
                                  alignment: widget.message.isOwnerMessage
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  scale:
                                      animationConfig.scaleDropDown / itemScale,
                                  child: widget.lowerWidget != null
                                      ? DeferPointer(child: widget.lowerWidget!)
                                      : null),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
}

class AnimationConfig extends Object {
  double blurDegree;
  double translateY;
  double scaleFactor;
  double scaleDropDown;

  AnimationConfig(
      {this.blurDegree = 10,
      this.translateY = 0,
      this.scaleFactor = 1,
      this.scaleDropDown = 1});

  AnimationConfig operator +(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          blurDegree: blurDegree + other.blurDegree,
          scaleFactor: scaleFactor + other.scaleFactor,
          translateY: translateY + other.translateY,
          scaleDropDown: scaleDropDown + other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          blurDegree: blurDegree + other,
          scaleFactor: scaleFactor + other,
          translateY: translateY + other,
          scaleDropDown: scaleDropDown + other);
    }
    throw UnsupportedError("unsupport operation");
  }

  AnimationConfig operator -(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          blurDegree: blurDegree - other.blurDegree,
          scaleFactor: scaleFactor - other.scaleFactor,
          translateY: translateY - other.translateY,
          scaleDropDown: scaleDropDown - other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          blurDegree: blurDegree - other,
          scaleFactor: scaleFactor - other,
          translateY: translateY - other,
          scaleDropDown: scaleDropDown - other);
    }
    throw UnsupportedError("unsupport operation");
  }

  AnimationConfig operator *(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          blurDegree: blurDegree * other.blurDegree,
          scaleFactor: scaleFactor * other.scaleFactor,
          translateY: translateY * other.translateY,
          scaleDropDown: scaleDropDown * other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          blurDegree: blurDegree * other,
          scaleFactor: scaleFactor * other,
          translateY: translateY * other,
          scaleDropDown: scaleDropDown * other);
    }
    throw UnsupportedError("unsupport operation");
  }

  AnimationConfig operator /(Object other) {
    if (other is AnimationConfig) {
      return AnimationConfig(
          blurDegree: blurDegree / other.blurDegree,
          scaleFactor: scaleFactor / other.scaleFactor,
          translateY: translateY / other.translateY,
          scaleDropDown: scaleDropDown / other.scaleDropDown);
    } else if (other is double || other is int) {
      other = other as double;
      return AnimationConfig(
          blurDegree: blurDegree / other,
          scaleFactor: scaleFactor / other,
          translateY: translateY / other,
          scaleDropDown: scaleDropDown / other);
    }
    throw UnsupportedError("unsupport operation");
  }

  @override
  bool operator ==(Object other) {
    if (other is AnimationConfig) {
      return blurDegree == other.blurDegree &&
          scaleFactor == other.scaleFactor &&
          translateY == other.translateY &&
          scaleDropDown == other.scaleDropDown;
    }
    throw UnsupportedError("unsupport operation");
  }

  @override
  int get hashCode =>
      blurDegree.hashCode +
      scaleFactor.hashCode +
      translateY.hashCode +
      scaleDropDown.hashCode;
}
