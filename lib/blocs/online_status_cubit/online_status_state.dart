part of 'online_status_cubit.dart';

enum OnlineStatus { success, off }

class OnlineStatusState extends Equatable {
  final OnlineStatus onlineStatus;
  final Map<String, List<User>> channelUsers;
  final Map<String, bool> onlineUsers;
  const OnlineStatusState(
      {this.onlineStatus = OnlineStatus.off,
      this.channelUsers = const {},
      this.onlineUsers = const {}});

  OnlineStatusState copyWith(
      {OnlineStatus? newOnlineStatus,
      Map<String, List<User>>? newChannelUsers,
      Map<String, bool>? newOnlineUsers}) {
    return OnlineStatusState(
        onlineStatus: newOnlineStatus ?? this.onlineStatus,
        channelUsers: newChannelUsers ?? this.channelUsers,
        onlineUsers: newOnlineUsers ?? this.onlineUsers);
  }

  @override
  List<Object> get props => [onlineStatus, channelUsers, onlineUsers];
}
