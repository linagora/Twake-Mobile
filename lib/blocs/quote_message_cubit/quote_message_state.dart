part of 'quote_message_cubit.dart';

enum QuoteMessageStatus {
  init,
  quoteDone,
  jumpToQuote,
  failed
}

class QuoteMessageState extends Equatable {
  final QuoteMessageStatus quoteMessageStatus;
  final List<Message> quoteMessage;

  const QuoteMessageState({
    this.quoteMessageStatus = QuoteMessageStatus.init,
    this.quoteMessage = const [],
  });

  QuoteMessageState copyWith({
    QuoteMessageStatus? newQuoteMessageStatus,
    List<Message>? newQuoteMessage,
  }) {
    return QuoteMessageState(
      quoteMessageStatus:
          newQuoteMessageStatus ?? this.quoteMessageStatus,
      quoteMessage: newQuoteMessage ?? this.quoteMessage,
    );
  }

  @override
  List<Object?> get props => [
        quoteMessageStatus,
        quoteMessage,
      ];
}
