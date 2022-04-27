import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:twake/models/company/company_role.dart';
import 'package:twake/models/deeplink/email_state.dart';
import 'package:twake/models/deeplink/email_status.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/invitation/email_invitation.dart';
import 'package:twake/models/invitation/email_invitation_response.dart';
import 'package:twake/models/invitation/email_invitation_response_status.dart';
import 'package:twake/models/workspace/workspace_role.dart';
import 'package:twake/repositories/workspaces_repository.dart';
import 'package:twake/utils/twake_error_messages.dart';
import 'invitation_email_state.dart';
import 'package:twake/utils/extensions.dart';

const emailListDisplayLimit = 3;

class InvitationEmailCubit extends Cubit<InvitationEmailState> {

  late final WorkspacesRepository _workspacesRepository;

  InvitationEmailCubit({WorkspacesRepository? workspacesRepository}) : super(const InvitationEmailState()) {
    if (workspacesRepository == null) {
      workspacesRepository = WorkspacesRepository();
    }
    _workspacesRepository = workspacesRepository;
  }

  void addEmail(String email) {
    List<EmailState> listEmailState = [...state.listEmailState];
    final newEmailList = listEmailState
      ..add(EmailState(email, EmailStatus.init, TwakeErrorMessage.None));
    emit(state.copyWith(
      newStatus: InvitationEmailStatus.addEmailSuccess,
      newEmailStates: newEmailList,
    ));
  }

  void sendEmails(List<String> listEmail) async {
    emit(state.copyWith(newStatus: InvitationEmailStatus.inProcessing));

    await _updateEmail(listEmail);

    // Validate email regex pattern
    final isAllEmailValidFormat = await _validateEmailFormat();
    if(!isAllEmailValidFormat) {
      emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
      return;
    }

    // Sent emails with API
    final listValidEmails = state.listEmailState
        .where((e) {
          // In case that there are both succeed and failed emails
          // and user is going to fix failed emails then re-send them,
          // we should not re-send succeed emails that sent before.
          final sentSucceedEmails = state.cachedSentSuccessEmails.map((e) => e.email).toList();
          return e.status == EmailStatus.inProcessing && !sentSucceedEmails.contains(e.email);
        })
        .map((e) => e.email)
        .toList();
    final invitationList = listValidEmails
      .map((e) => EmailInvitation(
          email: e, companyRole: CompanyRole.member, workspaceRole: WorkspaceRole.member))
      .toList();
    List<EmailInvitationResponse> resultList = [];
    try {
      resultList = await _workspacesRepository.inviteUser(
        Globals.instance.companyId!,
        Globals.instance.workspaceId!,
        invitationList,
      );
    } catch (e) {
      Logger().e('ERROR during invite user via email:\n$e');
    }
    // Checking state.cachedSentSuccessEmails.isEmpty to make sure we can continue next steps
    // if there was some succeed emails before.
    if(resultList.isEmpty && state.cachedSentSuccessEmails.isEmpty) {
      emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
      return;
    }

    // Update status of sending email to UI
    final resultListStates = resultList.map((e) {
      return e.status == EmailInvitationResponseStatus.ok
          ? EmailState(e.email, EmailStatus.valid, TwakeErrorMessage.None)
          : EmailState(e.email, EmailStatus.invalid, e.message?.twakeErrorByStringMessage);
    }).toList();
    final updatedEmailStates = [...resultListStates, ...state.cachedSentSuccessEmails]
        .toSet()
        .toList();
    emit(state.copyWith(newEmailStates: updatedEmailStates));

    // Checking all sending email successfully or not to display result screen
    final sentSuccessEmails = updatedEmailStates
        .where((result) => result.status == EmailStatus.valid)
        .toList();
    emit(state.copyWith(newCachedSentSuccessEmails: sentSuccessEmails));

    final existFailedEmail =
        updatedEmailStates.any((emailState) => emailState.status == EmailStatus.invalid);
    if(existFailedEmail) {
      // Only allow go to success screen if there is no failed email,
      // in order to user can see detail of error message
      emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
      return;
    }

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
        newEmailStates: listEmail
            .map((e) => EmailState(e, EmailStatus.init, TwakeErrorMessage.None))
            .toList()));
  }

  Future<bool> _validateEmailFormat() async {
    int countErrorEmail = 0;
    final emailUpdatedState = state.listEmailState.map((e) {
      if(e.email.trim().isEmpty) {
        return e.copyWith(newStatus: EmailStatus.init);
      }
      if(e.isValid)
        return e.copyWith(newStatus: EmailStatus.inProcessing);
      else {
        countErrorEmail++;
        return e.copyWith(
          newStatus: EmailStatus.invalid,
          newErrorMessage: TwakeErrorMessage.EmailIsNotValidFormat,
        );
      }
    }).toList();
    emit(state.copyWith(
      newStatus: InvitationEmailStatus.verifyEmailSuccess,
      newEmailStates: emailUpdatedState,
    ));
    return countErrorEmail == 0;
  }

}