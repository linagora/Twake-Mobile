import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/widgets/message/message_tile.dart';
import 'package:twake/blocs/single_message_bloc.dart';

class ThreadMessagesList extends StatelessWidget {
  final List<Message> responses;
  ThreadMessagesList(this.responses);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        reverse: true,
        itemCount: responses.length,
        itemBuilder: (ctx, i) {
          return BlocProvider<SingleMessageBloc>(
            create: (_) => SingleMessageBloc(responses[i]),
            child: MessageTile(),
          );
        },
      ),
    );
  }
}
