import 'package:equatable/equatable.dart';
import 'package:twake/models/account/account.dart';

abstract class MentionState extends Equatable {
  const MentionState();
}

class MentionsInitial extends MentionState {
  const MentionsInitial();

  @override
  List<Object> get props => [];
}

class MentionsLoadSuccess extends MentionState {
  final List<Account> accounts;

  const MentionsLoadSuccess({required this.accounts});

  @override
  List<Object> get props => [accounts];
}
