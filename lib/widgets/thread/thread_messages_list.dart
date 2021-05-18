import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/threads_bloc/threads_bloc.dart';
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
        Divider(
          thickness: 1.0,
          height: 1.0,
          color: Color(0xffEEEEEE),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: MessageTile<T>(
            message: state.threadMessage,
            hideShowAnswers: true,
            key: ValueKey(state.threadMessage!.key),
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
            state.threadMessage!.respCountStr + ' responses',
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
          MessageTile<T>(
            message: state.messages!.last,
            key: ValueKey(state.messages!.last!.key),
          ),
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

  double? appBarHeight;
  List<Widget> widgets = [];

  List<Message?>? _messages = <Message>[];

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
    return BlocBuilder<ThreadsBloc<T>, MessagesState>(
      builder: (ctx, state) {
        if (state is MessagesLoaded) {
          _messages = state.messages;
        }
        return Flexible(
          child: state is MessagesLoaded
              ? ListView.builder(
                  controller: _controller,
                  physics: _physics,
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: _messages!.length,
                  itemBuilder: (context, i) {
                    if (i == _messages!.length - 1) {
                      return buildThreadMessageColumn(state);
                    } else {
                      return MessageTile<T>(
                        message: _messages![i],
                        key: ValueKey(_messages![i]!.key),
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
