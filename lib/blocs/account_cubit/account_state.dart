part of 'account_cubit.dart';

abstract class AccountState extends Equatable {
  const AccountState();
}

class AccountInitial extends AccountState {
  const AccountInitial();

  @override
  List<Object> get props => [];
}

class AccountLoadInProgress extends AccountState {
  const AccountLoadInProgress();

  @override
  List<Object> get props => [];
}

class AccountLoadSuccess extends AccountState {
  final Account account;
  final int hash;

  const AccountLoadSuccess({
    required this.account,
    required this.hash,
  });

  @override
  List<Object?> get props => [hash];
}

class AccountLoadFailure extends AccountState {
  final String message;

  const AccountLoadFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
