part of 'quote_message_cubit.dart';

enum QuoteMessageStatus { init, quoteDone, jumpToQuote, failed }

class QuoteMessageState extends Equatable {
  final QuoteMessageStatus quoteMessageStatus;
  final List<Message> quoteMessage;
  final int quoteMessageIndex;

  const QuoteMessageState(
      {this.quoteMessageStatus = QuoteMessageStatus.init,
      this.quoteMessage = const [],
      this.quoteMessageIndex = -1});

  QuoteMessageState copyWith(
      {QuoteMessageStatus? newQuoteMessageStatus,
      List<Message>? newQuoteMessage,
      int? newQuoteMessageIndex}) {
    return QuoteMessageState(
        quoteMessageStatus: newQuoteMessageStatus ?? this.quoteMessageStatus,
        quoteMessage: newQuoteMessage ?? this.quoteMessage,
        quoteMessageIndex: newQuoteMessageIndex ?? this.quoteMessageIndex);
  }

  @override
  List<Object?> get props =>
      [quoteMessageStatus, quoteMessage, quoteMessageIndex];
}
