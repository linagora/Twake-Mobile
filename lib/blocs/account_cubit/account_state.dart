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

class AccountLoading extends AccountState {
  const AccountLoading();

  @override
  List<Object> get props => [];
}

class AccountLoaded extends AccountState {
  final String userName;
  final String firstName;
  final String lastName;
  final String picture;
  final String language;
  final List<LanguageOption> availableLanguages;

  const AccountLoaded({
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

class AccountUpdating extends AccountState {
  final String firstName;
  final String lastName;
  final String language;
  final String oldPassword;
  final String newPassword;

  const AccountUpdating({
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

class AccountUpdated extends AccountState {
  final String firstName;
  final String lastName;
  final String language;
  final String oldPassword;
  final String newPassword;

  const AccountUpdated({
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

class AccountSaving extends AccountState {
  final bool shouldUploadPicture;

  AccountSaving({this.shouldUploadPicture = false});

  @override
  List<Object> get props => [shouldUploadPicture];
}

class AccountSaved extends AccountState {
  final String firstName;
  final String lastName;
  final String language;

  const AccountSaved({
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

class AccountPictureUploaded extends AccountState {
  final String link;

  const AccountPictureUploaded(this.link);

  @override
  List<Object> get props => [link];
}

class AccountError extends AccountState {
  final String message;

  const AccountError({this.message});

  @override
  List<Object> get props => [message];
}

class AccountFlowStageUpdated extends AccountState {
  final AccountFlowStage stage;

  const AccountFlowStageUpdated({this.stage});

  @override
  List<Object> get props => [stage];
}
