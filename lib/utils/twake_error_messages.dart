import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum TwakeErrorMessage {
  None,
  EmailIsNotValidFormat,
  UserAlreadyInWorkspace,
  UnableInviteUser,
  PendingUserIsExist,
}

extension TwakeErrorMessageExtension on TwakeErrorMessage {

  String message(BuildContext context) {
    switch (this) {
      case TwakeErrorMessage.EmailIsNotValidFormat:
        return AppLocalizations.of(context)?.emailIsNotValid ?? '';
      case TwakeErrorMessage.UserAlreadyInWorkspace:
        return AppLocalizations.of(context)?.userAlreadyInWorkspace ?? '';
      case TwakeErrorMessage.UnableInviteUser:
        return AppLocalizations.of(context)?.unableInviteUser ?? '';
      case TwakeErrorMessage.PendingUserIsExist:
        return AppLocalizations.of(context)?.pendingUserExist ?? '';
      default:
        return AppLocalizations.of(context)?.somethingWasWrong ?? '';
    }
  }

}