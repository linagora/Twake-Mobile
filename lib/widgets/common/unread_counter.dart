import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class UnreadCounter extends StatefulWidget {
  // listen for position of elements in a list change
  final ItemPositionsListener itemPositionsListener;
  final int counter;
  // callback when user click on down button
  final void Function()? onPressed;

  UnreadCounter(
      {required this.itemPositionsListener,
      required this.counter,
      required this.onPressed});

  @override
  State<StatefulWidget> createState() => _UnreadCounterState();
}

class _UnreadCounterState extends State<UnreadCounter> {
  int count = 9999;
  int _counter = 0;

  @override
  initState() {
    super.initState();
    //count = _getLatestItemIndex();
    _counter = widget.counter;
  }

  @override
  void didUpdateWidget(covariant UnreadCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.counter != this.widget.counter) {
      _counter = this.widget.counter;
    }
  }

  // get index of latest visible item in viewport counting from below to top
  int _getLatestItemIndex() {
    var positions = widget.itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      return positions
              .where((position) => position.itemTrailingEdge > 0)
              .reduce((min, ItemPosition position) =>
                  position.itemTrailingEdge < min.itemTrailingEdge
                      ? position
                      : min)
              .index ~/
          2;
    } else {
      return 9999;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _counter > 0
        ? Container(
            width: 36,
            height: 50,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 6,
                    child: Icon(
                      Icons.expand_more,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    onPressed: () {
                      if (widget.onPressed != null) {
                        widget.onPressed!();
                      }
                    },
                  ),
                ),
                ValueListenableBuilder<Iterable<ItemPosition>>(
                  valueListenable: widget.itemPositionsListener.itemPositions,
                  builder: ((context, positions, child) {
                    count = min(count, _getLatestItemIndex());

                    return count > 0 && count <= _counter
                        ? Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Text("$count",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)))
                        : Container();
                  }),
                ),
              ],
              fit: StackFit.loose,
              alignment: Alignment.topCenter,
            ),
          )
        : Container();
  }
}
