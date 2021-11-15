import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:twake/models/company/company_role.dart';
import 'package:twake/models/deeplink/email_state.dart';
import 'package:twake/models/deeplink/email_status.dart';
import 'package:twake/models/invitation/email_invitation.dart';
import 'package:twake/models/invitation/email_invitation_response.dart';
import 'package:twake/models/invitation/email_invitation_response_status.dart';
import 'package:twake/models/workspace/workspace_role.dart';
import 'package:twake/repositories/workspaces_repository.dart';
import 'invitation_email_state.dart';

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
    final newEmailList = listEmailState..add(EmailState(email, EmailStatus.init));
    emit(state.copyWith(newStatus: InvitationEmailStatus.addEmailSuccess, newEmailStates: newEmailList));
  }

  void sendEmails(List<String> listEmail) async {
    emit(state.copyWith(newStatus: InvitationEmailStatus.inProcessing));

    await _updateEmail(listEmail);

    final isAllEmailValid = await _validateEmailFormat();

    if(isAllEmailValid) {
      final listEmails = state.listEmailState.where((e) =>
          e.status == EmailStatus.valid).map((e) =>
          e.email).toList();

      if (listEmails.isNotEmpty) {
        final invitationList = listEmails
            .map((e) => EmailInvitation(email: e, companyRole: CompanyRole.member, workspaceRole: WorkspaceRole.member))
            .toList();

        // Sent email with API
        List<EmailInvitationResponse> resultList = [];
        try {
          resultList = await _workspacesRepository.inviteUser(invitationList);
        } catch (e) {
          Logger().e('ERROR during invite user via email:\n$e');
        }
        if(resultList.isEmpty) {
          emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
          return;
        }

        // Update status of sending email to UI
        final updatedEmailStates = resultList
            .map((e) {
              return e.status == EmailInvitationResponseStatus.ok
                ? EmailState(e.email, EmailStatus.valid)
                : EmailState(e.email, EmailStatus.invalid);
            })
            .toList();
        emit(state.copyWith(newEmailStates: updatedEmailStates));

        // Checking all sending email successfully or not to display result screen
        final sentSuccessEmails = resultList
            .where((result) => result.status == EmailInvitationResponseStatus.ok)
            .map((e) => EmailState(e.email, EmailStatus.valid))
            .toList();
        if(sentSuccessEmails.isEmpty) {
          emit(state.copyWith(newStatus: InvitationEmailStatus.sendEmailFail));
          return;
        }
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

  Future<bool> _validateEmailFormat() async {
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

}