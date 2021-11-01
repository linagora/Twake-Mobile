import 'package:equatable/equatable.dart';
import 'package:twake/models/deeplink/email_status.dart';

class EmailState extends Equatable {
  final String email;
  final EmailStatus status;

  const EmailState(this.email, this.status);

  const EmailState.init() : this('', EmailStatus.init);

  EmailState copyWith({String? newEmail, EmailStatus? newStatus}) {
    return EmailState(
        newEmail ?? this.email,
        newStatus ?? this.status
    );
  }

  @override
  List<Object> get props => [email, status];

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