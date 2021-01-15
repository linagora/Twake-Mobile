import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class LoadUser extends UserEvent {
  final String userId;

  const LoadUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class RemoveUser extends UserEvent {
  final String userId;

  const RemoveUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUsers extends UserEvent {
  final String request;

  LoadUsers(this.request);

  @override
  List<Object> get props => [request];
}
