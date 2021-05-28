import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/member.dart';

abstract class MemberState extends Equatable {
  const MemberState();
}

class MemberInitial extends MemberState {
  @override
  List<Object> get props => [];
}

class MembersLoaded extends MemberState {
  final String? channelId;
  final List<Member?>? members;

  MembersLoaded({required this.channelId, required this.members});

  @override
  List<Object?> get props => [channelId, members];
}

class MembersAdded extends MemberState {
  final String? channelId;
  final List<Member> members;

  MembersAdded({required this.channelId, required this.members});

  @override
  List<Object?> get props => [channelId, members];
}

class MembersDeleted extends MemberState {
  final String? channelId;
  final List<Member> members;

  MembersDeleted({required this.channelId, required this.members});

  @override
  List<Object?> get props => [channelId, members];
}

class SelfDeleted extends MemberState {
  final String channelId;

  SelfDeleted({required this.channelId});

  @override
  List<Object> get props => [channelId];
}

class MembersError extends MemberState {
  final String message;

  MembersError(this.message);

  @override
  List<Object> get props => [message];
}
