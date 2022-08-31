import 'package:equatable/equatable.dart';
import 'package:twake/models/message/message.dart';

abstract class UnreadMessagesState extends Equatable {
  const UnreadMessagesState();
}

class UnreadMessagesInitial extends UnreadMessagesState {
  const UnreadMessagesInitial();

  @override
  List<Object?> get props => [];
}

class NoUnreadMessages extends UnreadMessagesState {
  const NoUnreadMessages();

  @override
  List<Object?> get props => [];
}

class UnreadMessagesFound extends UnreadMessagesState {
  final int unreadCounter;
  final int userLastAccess;

  UnreadMessagesFound(
      {required this.unreadCounter, required this.userLastAccess});

  @override
  List<Object?> get props => [unreadCounter, userLastAccess];
}

class UnreadMessagesThreadFound extends UnreadMessagesFound {
  final int unreadCounter;
  final int userLastAccess;
  final List<Message> unreadThreads;
  final Message? firstUnreadThread;

  UnreadMessagesThreadFound(
      {required this.unreadCounter,
      required this.userLastAccess,
      required this.unreadThreads,
      this.firstUnreadThread})
      : super(unreadCounter: unreadCounter, userLastAccess: userLastAccess);

  @override
  List<Object?> get props =>
      [unreadCounter, userLastAccess, unreadThreads, firstUnreadThread];
}
