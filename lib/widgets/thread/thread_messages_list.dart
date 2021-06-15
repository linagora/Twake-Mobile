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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            message.content.originalStr! + ' responses',
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
          MessageTile<ThreadMessagesCubit>(
            message: state.messages.last,
            key: ValueKey(state.messages.last),
          ),
        if (state is MessagesInitial)
          Center(
              /* to add the new state is needed 
                child: Text(
                  state is ErrorLoadingMessages
                      ? 'Couldn\'t load messages, no connection'
                      : 'No responses yet',
                ),*/
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

  @override
  void initState() {
    super.initState();

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
          child: state is MessagesLoadSuccess
              ? ListView.builder(
                  controller: _controller,
                  physics: _physics,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    if (i == _messages.length - 1) {
                      return buildThreadMessageColumn(_messages[i]);
                    } else {
                      return MessageTile<ThreadMessagesCubit>(
                        message: _messages[i],
                        key: ValueKey(_messages[i]),
                      );
                    }
                  },
                )
              : SingleChildScrollView(
                  child: buildThreadMessageColumn(_messages[0])),
        );
      },
    );
  }
}
