import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/models/message/message.dart';

part 'quote_message_state.dart';

class QuoteMessageCubit extends Cubit<QuoteMessageState> {
  QuoteMessageCubit()
      : super(QuoteMessageState(quoteMessageStatus: QuoteMessageStatus.init));

  void addQuoteMessage(Message message) {
    emit(state.copyWith(
        newQuoteMessageStatus: QuoteMessageStatus.quoteDone,
        newQuoteMessage: [message]));
  }

  void emitQuoteDoneState() {
    emit(state.copyWith(
      newQuoteMessageStatus: QuoteMessageStatus.quoteDone,
    ));
  }

  void jumpToMessage({required Message message, required bool isDirect}) async {
    final stateMessagesCubit = Get.find<ChannelMessagesCubit>().state;
    if (stateMessagesCubit is MessagesLoadSuccess) {
      // set isInHistory to false
      Get.find<ChannelMessagesCubit>().emit(MessagesLoadSuccess(
          messages: stateMessagesCubit.messages,
          hash: stateMessagesCubit.hash,
          isInHistory: false));

      // if message is in the state
      final messageRes = stateMessagesCubit.messages.firstWhereOrNull(
        (m) => m.id == message.id,
      );
      if (messageRes != null) {
        final res = stateMessagesCubit.messages.indexOf(messageRes);
        emit(state.copyWith(
            newQuoteMessageIndex: res,
            newQuoteMessage: [message],
            newQuoteMessageStatus: QuoteMessageStatus.jumpToQuote));
      } else {
        // if the message is not in the state, we need to fetch it

        final messagesAround = await Get.find<ChannelMessagesCubit>()
            .getMessagesAroundSelectedMessage(
                message: message, isDirect: isDirect);
        final messagesCubit =
            Get.find<ChannelMessagesCubit>().state as MessagesLoadSuccess;
        final messageRes = messagesCubit.messages.firstWhereOrNull(
          (m) => m.id == message.id,
        );
        if (messageRes != null) {
          final res = messagesAround.indexOf(messageRes);
          if (res != -1)
            emit(state.copyWith(
                newQuoteMessageIndex: res,
                newQuoteMessage: [message],
                newQuoteMessageStatus: QuoteMessageStatus.jumpToQuote));
        }
      }
    }
  }

  void init() {
    emit(QuoteMessageState(
      quoteMessageStatus: QuoteMessageStatus.init,
    ));
  }

  void failed() {
    emit(QuoteMessageState(
      quoteMessageStatus: QuoteMessageStatus.failed,
    ));
  }
}
