part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
}

class FetchMessageEvent extends MessageEvent {
  final String channelId;
  final String? threadId;
  final bool isDirect;
  final bool empty;

  FetchMessageEvent({
    required this.channelId,
    this.threadId,
    this.isDirect = false,
    this.empty = false,
  });

  @override
  List<Object?> get props => [];
}
