import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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

  void jumpToMessage(Message message) {
    emit(QuoteMessageState(
        quoteMessageStatus: QuoteMessageStatus.jumpToQuote,
        quoteMessage: [message]));
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
