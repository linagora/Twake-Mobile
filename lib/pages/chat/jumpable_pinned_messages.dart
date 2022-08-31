import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';

class JumpablePinnedMessages extends StatefulWidget {
  final Widget child;
  final List<Message> messages;
  final Function(List<Message> messages, Message jumpedMessage) jumpToMessage;
  final bool isDirect;

  JumpablePinnedMessages(
      {required this.child,
      required this.messages,
      required this.jumpToMessage,
      required this.isDirect});

  @override
  State<StatefulWidget> createState() => _JumpablePinnedMessagesState();
}

class _JumpablePinnedMessagesState extends State<JumpablePinnedMessages> {

  @override
  Widget build(BuildContext context) {
    return BlocListener<PinnedMessageCubit, PinnedMessageState>(
        bloc: Get.find<PinnedMessageCubit>(),
        listenWhen: (previous, _) =>
            previous.pinnedMesssageStatus == PinnedMessageStatus.selected,
        listener: (context, state) async {
          int selected = state.selected;
          Message jumpMessage = state.pinnedMessageList[selected];

          if (widget.messages.contains(jumpMessage)) {
            widget.jumpToMessage(widget.messages, jumpMessage);
            return;
          }
          // jumpMessage is in the same thread or chat
          if (widget.messages.isNotEmpty &&
              widget.messages[0].threadId == jumpMessage.threadId) {
            // get messages around selectec pinned message
            List<Message> messages = await Get.find<PinnedMessageCubit>()
                .getMessagesAroundSelectedMessage(
                    message: jumpMessage, isDirect: widget.isDirect);

            // update the current messages in chat
            Get.find<ChannelMessagesCubit>().fetchMessagesAroundPinned(
                messages: messages, pinnedMessage: jumpMessage);
            return;
          }
          // if current messages in thread, exit the current thread
          if (NavigatorService.instance.isInThread) {
            NavigatorService.instance.pop();
          }
          // if message is in different thread, navigate to it
          if (jumpMessage.inThread) {
            NavigatorService.instance.navigate(
              channelId: jumpMessage.channelId,
              threadId: jumpMessage.threadId,
              reloadThreads: false,
              pinnedMessage: jumpMessage,
            );
          }
        },
        child: widget.child);
  }
}
