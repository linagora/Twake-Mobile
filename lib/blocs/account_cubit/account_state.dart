part of 'account_cubit.dart';

abstract class AccountState extends Equatable {
  final String userName;
  final String firstName;
  final String lastName;
  final String oldPassword;
  final String newPassword;
  final String picture;
  final String language;
  final List<LanguageOption> availableLanguages;

  const AccountState({
    this.userName,
    this.firstName,
    this.lastName,
    this.oldPassword,
    this.newPassword,
    this.picture,
    this.language,
    this.availableLanguages,
  });

  @override
  List<Object> get props => [
        userName,
        firstName,
        lastName,
        oldPassword,
        newPassword,
        picture,
        language,
        availableLanguages,
      ];
}

class AccountInitial extends AccountState {
  const AccountInitial({
    String userName,
    String firstName,
    String lastName,
    String picture,
    String language,
    List<LanguageOption> availableLanguages,
  }) : super(
          userName: userName,
          firstName: firstName,
          lastName: lastName,
          picture: picture,
          language: language,
          availableLanguages: availableLanguages,
        );
}

class AccountLoading extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountLoaded extends AccountState {
  const AccountLoaded({
    String userName,
    String firstName,
    String lastName,
    String picture,
    String language,
    List<LanguageOption> availableLanguages,
  }) : super(
          userName: userName,
          firstName: firstName,
          lastName: lastName,
          picture: picture,
          language: language,
          availableLanguages: availableLanguages,
        );
}

class AccountUpdating extends AccountState {
  @override
  List<Object> get props => [];
}

class AccountUpdated extends AccountState {
  const AccountUpdated({
    String userName,
    String firstName,
    String lastName,
    String oldPassword,
    String newPassword,
    String picture,
    String language,
    List<LanguageOption> availableLanguages,
  }) : super(
          userName: userName,
          firstName: firstName,
          lastName: lastName,
          oldPassword: oldPassword,
          newPassword: newPassword,
          picture: picture,
          language: language,
          availableLanguages: availableLanguages,
        );
}

class AccountSaving extends AccountState {
  final bool isPictureUpdating;

  AccountSaving({this.isPictureUpdating = false});

  @override
  List<Object> get props => [isPictureUpdating];
}

class AccountSaved extends AccountState {
  const AccountSaved({
    String userName,
    String firstName,
    String lastName,
    String picture,
    String language,
    List<LanguageOption> availableLanguages,
  }) : super(
          userName: userName,
          firstName: firstName,
          lastName: lastName,
          picture: picture,
          language: language,
          availableLanguages: availableLanguages,
        );
}

class AccountError extends AccountState {
  final String message;

  AccountError({this.message});

  @override
  List<Object> get props => [message];
}

class AccountFlowStageUpdated extends AccountState {
  final AccountFlowStage stage;

  const AccountFlowStageUpdated(this.stage);

  @override
  List<Object> get props => [stage];
}
