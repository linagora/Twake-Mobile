part of 'base_message_bloc.dart';

abstract class BaseMessageEvent extends Equatable {
  const BaseMessageEvent();
}

class FetchMessageEvent extends BaseMessageEvent {
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
