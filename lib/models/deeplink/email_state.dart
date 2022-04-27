import 'package:equatable/equatable.dart';
import 'package:twake/models/deeplink/email_status.dart';
import 'package:twake/utils/twake_error_messages.dart';

class EmailState extends Equatable {
  final String email;
  final EmailStatus status;
  final TwakeErrorMessage? errorMessage;

  const EmailState(this.email, this.status, this.errorMessage);

  const EmailState.init() : this('', EmailStatus.init, TwakeErrorMessage.None);

  EmailState copyWith({
    String? newEmail,
    EmailStatus? newStatus,
    TwakeErrorMessage? newErrorMessage,
  }) {
    return EmailState(
        newEmail ?? this.email,
        newStatus ?? this.status,
        newErrorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];

}

extension EmailStateExtension on EmailState {
  bool get isValid {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) {
      return false;
    }
    return true;
  }
}