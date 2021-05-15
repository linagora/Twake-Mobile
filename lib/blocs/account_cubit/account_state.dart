part of 'account_cubit.dart';

abstract class AccountState extends Equatable {
  const AccountState();
}

class AccountInitial extends AccountState {
  final AccountFlowStage stage;

  const AccountInitial({@required this.stage});

  @override
  List<Object> get props => [stage];
}

class AccountLoadInProgress extends AccountState {
  const AccountLoadInProgress();

  @override
  List<Object> get props => [];
}

class AccountLoadSuccess extends AccountState {
  final String userName;
  final String firstName;
  final String lastName;
  final String picture;
  final String language;
  final List<LanguageOption> availableLanguages;

  const AccountLoadSuccess({
    this.userName,
    this.firstName,
    this.lastName,
    this.picture,
    this.language,
    this.availableLanguages,
  });

  @override
  List<Object> get props => [
        userName,
        firstName,
        lastName,
        picture,
        language,
        availableLanguages,
      ];
}

class AccountLoadFailure extends AccountState {
  final String message;

  const AccountLoadFailure({this.message});

  @override
  List<Object> get props => [message];
}

class AccountUpdateInProgress extends AccountState {
  final String firstName;
  final String lastName;
  final String language;
  final String oldPassword;
  final String newPassword;

  const AccountUpdateInProgress({
    this.firstName,
    this.lastName,
    this.language,
    this.oldPassword,
    this.newPassword,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        language,
        oldPassword,
        newPassword,
      ];
}

class AccountUpdateSuccess extends AccountState {
  final String firstName;
  final String lastName;
  final String language;
  final String oldPassword;
  final String newPassword;

  const AccountUpdateSuccess({
    this.firstName,
    this.lastName,
    this.language,
    this.oldPassword,
    this.newPassword,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        language,
        oldPassword,
        newPassword,
      ];
}

class AccountSaveInProgress extends AccountState {
  const AccountSaveInProgress();

  @override
  List<Object> get props => [];
}

class AccountSaveSuccess extends AccountState {
  final String firstName;
  final String lastName;
  final String language;

  const AccountSaveSuccess({
    this.firstName,
    this.lastName,
    this.language,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        language,
      ];
}

class AccountSaveFailure extends AccountState {
  final String message;

  const AccountSaveFailure({this.message});

  @override
  List<Object> get props => [message];
}

// Picture

class AccountPictureUploadInProgress extends AccountState {
  const AccountPictureUploadInProgress();

  @override
  List<Object> get props => [];
}

class AccountPictureUploadSuccess extends AccountState {
  final String link;

  const AccountPictureUploadSuccess({this.link});

  @override
  List<Object> get props => [link];
}

class AccountPictureUploadFailure extends AccountState {
  final String message;

  const AccountPictureUploadFailure({this.message});

  @override
  List<Object> get props => [message];
}

// Flow stages

class AccountFlowStageUpdateSuccess extends AccountState {
  final AccountFlowStage stage;

  const AccountFlowStageUpdateSuccess({this.stage});

  @override
  List<Object> get props => [stage];
}

class AccountFlowStageUpdateFailure extends AccountState {
  final String message;

  const AccountFlowStageUpdateFailure({this.message});

  @override
  List<Object> get props => [message];
}
