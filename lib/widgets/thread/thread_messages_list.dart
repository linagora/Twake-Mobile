import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/base_channel_bloc.dart';
import 'package:twake/blocs/threads_bloc.dart';
import 'package:twake/widgets/message/message_tile.dart';
import 'package:twake/models/message.dart';

class ThreadMessagesList<T extends BaseChannelBloc> extends StatefulWidget {
  ThreadMessagesList();

  @override
  _ThreadMessagesListState<T> createState() => _ThreadMessagesListState<T>();
}

class _ThreadMessagesListState<T extends BaseChannelBloc>
    extends State<ThreadMessagesList<T>> {
  Widget buildThreadMessageColumn(MessagesState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<T>(
              message: state.threadMessage, hideShowAnswers: true),
        ),
        Divider(
          thickness: 1.0,
          height: 1.0,
          color: Color(0xffEEEEEE),
        ),
        SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            state.threadMessage.respCountStr + ' responses',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: Color(0xff92929C),
            ),
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        Divider(
          thickness: 1.0,
          height: 1.0,
          color: Color(0xffEEEEEE),
        ),
        SizedBox(
          height: 12.0,
        ),
        if (state is MessagesLoaded)
          MessageTile<T>(message: state.messages.last),
        if (state is MessagesEmpty)
          Center(
            child: Text(
              state is ErrorLoadingMessages
                  ? 'Couldn\'t load messages, no connection'
                  : 'No responses yet',
            ),
          ),
        if (state is MessagesLoading)
          Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  var _messages = <Message>[];
  var _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        _itemScrollController?.jumpTo(index: _messages.length);
      }
    });
    _itemPositionsListener.itemPositions.addListener(() {
      final lastPosition = _itemPositionsListener.itemPositions.value.last;
      final index = lastPosition.index;
      if (_lastIndex != index) {
      print(_lastIndex);
      _lastIndex = index;
      _itemScrollController?.jumpTo(index: _lastIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadsBloc<T>, MessagesState>(
      builder: (ctx, state) {
        if (state is MessagesLoaded) {
          _messages = state.messages.reversed.toList();
          if (_itemScrollController.isAttached) {
            _itemScrollController?.jumpTo(
              index: _messages.length,
              alignment: 1.0,
            );
          }
        }
        return Expanded(
          child: state is MessagesLoaded
              ? ScrollablePositionedList.builder(
                  reverse: false,
                  initialAlignment: 0.0,
                  initialScrollIndex: 0,
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return buildThreadMessageColumn(state);
                    } else {
                      return MessageTile<T>(
                        message: _messages[i],
                        key: ValueKey(_messages[i].id),
                      );
                    }
                  },
                )
              : SingleChildScrollView(child: buildThreadMessageColumn(state)),
        );
      },
    );
  }
}
