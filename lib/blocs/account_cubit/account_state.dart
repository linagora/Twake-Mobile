part of 'account_cubit.dart';

abstract class AccountState extends Equatable {
  const AccountState();
}

class AccountInitial extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountLoading extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountLoaded extends AccountState {
  final String userName;
  final String firstName;
  final String lastName;
  final String picture;
  final String language;

  AccountLoaded({
    this.userName,
    this.firstName,
    this.lastName,
    this.picture,
    this.language,
  });

  @override
  List<Object> get props => [
        userName,
        firstName,
        lastName,
        picture,
        language,
      ];
}

class AccountSaving extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountSaved extends AccountState {
  final String userName;
  final String firstName;
  final String lastName;
  final String picture;
  final String language;

  AccountSaved({
    this.userName,
    this.firstName,
    this.lastName,
    this.picture,
    this.language,
  });

  @override
  List<Object> get props => [
        userName,
        firstName,
        lastName,
        picture,
        language,
      ];
}
