import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:twake/models/deeplink/email_state.dart';
import 'package:twake/models/deeplink/email_status.dart';
import 'invitation_email_state.dart';

const emailListDisplayLimit = 3;

class InvitationEmailCubit extends Cubit<InvitationEmailState> {
  InvitationEmailCubit() : super(const InvitationEmailState());

  void addEmail(String email) {
    List<EmailState> listEmailState = [...state.listEmailState];
    final newEmailList = listEmailState..add(EmailState(email, EmailStatus.init));
    emit(state.copyWith(newStatus: InvitationEmailStatus.addEmailSuccess, newEmailStates: newEmailList));
  }

  void sendEmails(String subject, String body, List<String> listEmail) async {
    emit(state.copyWith(newStatus: InvitationEmailStatus.inProcessing));

    await _updateEmail(listEmail);

    final isAllEmailValid = await _verifyEmail();

    if(isAllEmailValid) {
      final listEmails = state.listEmailState.where((e) =>
          e.status == EmailStatus.valid).map((e) =>
          e.email).toList();
      if (listEmails.isNotEmpty) {
        final result = await _sendEmail(subject, body, listEmails);
        if (result) {
          final sentSuccessEmails = state.listEmailState.where((element) => element.status == EmailStatus.valid).toList();
          emit(state.copyWith(newCachedSentSuccessEmails: sentSuccessEmails));
          if(sentSuccessEmails.length > emailListDisplayLimit) {
            final getInRangeEmailStates = sentSuccessEmails.getRange(0, emailListDisplayLimit).toList();
            emit(state.copyWith(
                newStatus: InvitationEmailStatus.sendEmailSuccess,
                newEmailStates: getInRangeEmailStates));
          } else {
            emit(state.copyWith(
                newStatus: InvitationEmailStatus.sendEmailSuccess,
                newEmailStates: sentSuccessEmails));
          }
        } else {
          emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
        }
      } else {
        emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
      }
    } else {
      emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
    }
  }

  void showFullSentSuccessEmail() {
    final cachedFullList = state.cachedSentSuccessEmails;
    emit(state.copyWith(
        newStatus: InvitationEmailStatus.sendEmailSuccessShowAll,
        newEmailStates: cachedFullList,
        newCachedSentSuccessEmails: [])
    );
  }

  Future<void> _updateEmail(List<String> listEmail) async {
    emit(state.copyWith(
      newStatus: InvitationEmailStatus.updateEmailSuccess,
      newEmailStates: listEmail.map((e) => EmailState(e, EmailStatus.init)).toList()));
  }

  Future<bool> _verifyEmail() async {
    int countErrorEmail = 0;
    final emailUpdatedState = state.listEmailState.map((e) {
      if(e.email.trim().isEmpty) {
        return e.copyWith(newStatus: EmailStatus.init);
      }
      if(e.isValid)
        return e.copyWith(newStatus: EmailStatus.valid);
      else {
        countErrorEmail++;
        return e.copyWith(newStatus: EmailStatus.invalid);
      }
    }).toList();
    emit(state.copyWith(newStatus: InvitationEmailStatus.verifyEmailSuccess, newEmailStates: emailUpdatedState));
    return countErrorEmail == 0;
  }

  Future<bool> _sendEmail(String subject, String body, List<String> recipientList) async {
    final Email email = Email(
      subject: subject,
      body: body,
      recipients: recipientList,
    );
    return await FlutterEmailSender.send(email).then((value) {
      return true;
    }).onError((e, stackTrace) {
      Logger().e('Error occurred while sending invitation email: $e');
      return false;
    });
  }

}