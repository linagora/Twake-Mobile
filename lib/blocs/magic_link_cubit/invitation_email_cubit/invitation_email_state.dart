import 'package:equatable/equatable.dart';
import 'package:twake/models/deeplink/email_state.dart';

enum InvitationEmailStatus {
  init,
  inProcessing,
  addEmailSuccess,
  updateEmailSuccess,
  verifyEmailSuccess,
  sendEmailSuccess,
  sendEmailFail,
  sendEmailSuccessShowAll
}

class InvitationEmailState extends Equatable {
  final InvitationEmailStatus status;
  final List<EmailState> listEmailState;
  final List<EmailState> cachedSentSuccessEmails;

  const InvitationEmailState({
      this.status = InvitationEmailStatus.init,
      this.listEmailState = const [],
      this.cachedSentSuccessEmails = const []
  });

  InvitationEmailState copyWith({
    InvitationEmailStatus? newStatus,
    List<EmailState>? newEmailStates,
    List<EmailState>? newCachedSentSuccessEmails
  }) {
    return InvitationEmailState(
      status: newStatus ?? this.status,
      listEmailState: newEmailStates ?? this.listEmailState,
      cachedSentSuccessEmails: newCachedSentSuccessEmails ?? this.cachedSentSuccessEmails,
    );
  }

  @override
  List<Object> get props => [status, listEmailState, cachedSentSuccessEmails];
}
