import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
//import 'package:twake/widgets/message/message_tile.dart';
import 'package:twake/pages/chat/message_tile.dart';
import 'package:twake/widgets/common/reaction.dart';

class ThreadMessagesList<T extends BaseMessagesCubit> extends StatefulWidget {
  final Channel parentChannel;

  const ThreadMessagesList({required this.parentChannel});

  @override
  _ThreadMessagesListState createState() => _ThreadMessagesListState();
}

class _ThreadMessagesListState<T extends BaseMessagesCubit>
    extends State<ThreadMessagesList> {
  Widget buildThreadMessageColumn(Message message) {
    final state = Get.find<ThreadMessagesCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<ThreadMessagesCubit>(
            channel: widget.parentChannel,
            downBubbleSide: true,
            upBubbleSide: true,
            message: message,
            hideReaction: true,
            hideShowReplies: true,
            isThread: true,
            key: ValueKey(message.hash),
          ),
        ),
        if (state is MessagesLoadSuccess)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 15,
              ),
              Wrap(
                runSpacing: Dim.heightMultiplier,
                crossAxisAlignment: WrapCrossAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  ...message.reactions.map((r) {
                    return Reaction<T>(
                      message: message,
                      reaction: r,
                      isFirstInThread: true,
                    );
                  }),
                ],
              ),
              Spacer(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: state.messages.length - 1 > 1
                      ? Text(
                          '${state.messages.length - 1}' + ' replies ',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF818C99),
                          ),
                        )
                      : state.messages.length - 1 == 1
                          ? Text(
                              '${state.messages.length - 1}' + ' reply ',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Color(0xFF818C99),
                              ),
                            )
                          : Text(
                              '${state.messages.length - 1}' +
                                  ' there are no replies yet ',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Color(0xFF818C99),
                              ),
                            )),
            ],
          ),
        SizedBox(
          height: 8.0,
        ),
        Divider(
          thickness: 5.0,
          height: 2.0,
          color: Color(0xFFF6F6F6),
        ),
        SizedBox(
          height: 12.0,
        ),
        if (state is MessagesInitial)
          Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        if (state is MessagesLoadInProgress)
          Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  double? appBarHeight;
  List<Widget> widgets = [];
  List<Message> _messages = <Message>[];

  var _controller = ScrollController();
  ScrollPhysics _physics = BouncingScrollPhysics();
  bool upBubbleSide = false;
  bool downBubbleSide = false;
  @override
  void initState() {
    super.initState();

    final state = Get.find<ThreadMessagesCubit>().state;
    if (state is MessagesLoadSuccess) {
      _messages = state.messages;
    }

    _controller.addListener(() {
      // print(_controller.position.pixels);
      if (_controller.position.pixels > 100 &&
          _physics is! ClampingScrollPhysics) {
        setState(() => _physics = ClampingScrollPhysics());
      } else if (_physics is! BouncingScrollPhysics) {
        setState(() => _physics = BouncingScrollPhysics());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void bubbleSide(List<Message> messages, int index) {
    //conditions for determining the shape of the sides of the bubble
    //if there is only one message in the chat
    if (messages.length == 1) {
      upBubbleSide = true;
      downBubbleSide = true;
    } else {
      // boundary bubbles handling
      if (index == 0 || index == messages.length - 1) {
        if (index == 0) {
          if (messages[messages.length - index - 1].userId !=
              messages[messages.length - index - 1 - 1].userId) {
            upBubbleSide = true;
          } else {
            upBubbleSide = false;
          }
          downBubbleSide = true;
        }
        if (index == messages.length - 1) {
          if (messages[messages.length - index - 1].userId !=
              messages[messages.length - index - 1 + 1].userId) {
            downBubbleSide = true;
          } else {
            downBubbleSide = false;
          }
          upBubbleSide = true;
        }
      } else {
        // processing of all basic bubbles in the chat except of boundary values
        if (messages[messages.length - index - 1].userId !=
            messages[messages.length - index - 1 + 1].userId) {
          downBubbleSide = true;
        } else {
          downBubbleSide = false;
        }
        if (messages[messages.length - index - 1].userId !=
            messages[messages.length - index - 1 - 1].userId) {
          upBubbleSide = true;
        } else {
          upBubbleSide = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadMessagesCubit, MessagesState>(
      bloc: Get.find<ThreadMessagesCubit>(),
      builder: (ctx, state) {
        if (state is MessagesLoadSuccess) {
          _messages = state.messages;
        }
        return Flexible(
          child: state is MessagesLoadSuccess && _messages.length != 0
              ? ListView.builder(
                  controller: _controller,
                  physics: _physics,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    //conditions for determining the shape of the sides of the bubble
                    bubbleSide(_messages, index);

                    if (index == _messages.length - 1) {
                      return buildThreadMessageColumn(_messages.first);
                    } else if (index == _messages.length - 2) {
                      // the top side of the first answer in a thread should always be round
                      return MessageTile<ThreadMessagesCubit>(
                        message: _messages[_messages.length - 1 - index],
                        key: ValueKey(
                            _messages[_messages.length - 1 - index].hash),
                        channel: widget.parentChannel,
                        downBubbleSide: downBubbleSide,
                        upBubbleSide: true,
                        isThread: true,
                      );
                    } else {
                      return MessageTile<ThreadMessagesCubit>(
                        message: _messages[_messages.length - 1 - index],
                        key: ValueKey(
                            _messages[_messages.length - 1 - index].hash),
                        channel: widget.parentChannel,
                        downBubbleSide: downBubbleSide,
                        upBubbleSide: upBubbleSide,
                        isThread: true,
                      );
                    }
                  },
                )
              : SingleChildScrollView(
                  child: buildThreadMessageColumn(_messages.first),
                ),
        );
      },
    );
  }
}
