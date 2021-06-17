import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/widgets/message/message_tile.dart';

class ThreadMessagesList extends StatefulWidget {
  ThreadMessagesList();

  @override
  _ThreadMessagesListState createState() => _ThreadMessagesListState();
}

class _ThreadMessagesListState extends State<ThreadMessagesList> {
  Widget buildThreadMessageColumn(Message message) {
    final state = Get.find<ThreadMessagesCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(
          thickness: 1.0,
          height: 1.0,
          color: Color(0xffEEEEEE),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<ThreadMessagesCubit>(
            message: message,
            hideShowAnswers: true,
            key: ValueKey(message.content.originalStr),
          ),
        ),
        Divider(
          thickness: 1.0,
          height: 1.0,
          color: Color(0xffEEEEEE),
        ),
        SizedBox(
          height: 8.0,
        ),
        if (state is MessagesLoadSuccess)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '${state.messages.length}' + ' responses',
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
        if (state is MessagesLoadSuccess)
          state.messages.length > 0
              ? MessageTile<ThreadMessagesCubit>(
                  message: state.messages.last,
                  key: ValueKey(state.messages.last),
                )
              : Container(),
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
  Message? parentMessage;
  List<Message> _messages = <Message>[];

  var _controller = ScrollController();
  ScrollPhysics _physics = BouncingScrollPhysics();

  @override
  void initState() {
    super.initState();

    final state = Get.find<ThreadMessagesCubit>().state;
    if (state is MessagesLoadSuccess) {
      _messages = state.messages;
      parentMessage = state.parentMessage;
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
                  itemBuilder: (context, i) {
                    //  print(i);
                    if (i == _messages.length - 1) {
                      return buildThreadMessageColumn(parentMessage!);
                    } else {
                      return MessageTile<ThreadMessagesCubit>(
                        message: _messages[_messages.length - 1 - i],
                        key: ValueKey(_messages.length - 1 - i),
                      );
                    }
                  },
                )
              : SingleChildScrollView(
                  child: buildThreadMessageColumn(parentMessage!),
                ),
        );
      },
    );
  }
}
