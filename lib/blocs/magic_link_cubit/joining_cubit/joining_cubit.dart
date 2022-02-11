import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/joining_cubit/joining_state.dart';
import 'package:twake/models/deeplink/join/workspace_join_request.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/magic_link_repository.dart';

class JoiningCubit extends Cubit<JoiningState> {

  late final MagicLinkRepository _repository;

  JoiningCubit({MagicLinkRepository? repository}) : super(JoiningStateInit()) {
    if (repository == null) {
      repository = MagicLinkRepository();
    }
    _repository = repository;
  }

  // Additional handle the incoming link from another supported server
  // Look at story #1155 for more detail
  Future<void> checkServerDifference(String token, String incomingHost) async {
    emit(JoiningStateCheckingHost());
    final currentHost = Globals.instance.host;
    bool isDifferenceHost = incomingHost != currentHost;
    if(isDifferenceHost) {
      emit(JoiningWithDifferenceHost());
    } else {
      checkTokenAvailable(token, incomingHost);
    }
  }

  void forceLogoutCurrentServer(String token, String incomingHost) async {
    final result = await _handleDifferenceServer();
    if(!result) return;
    emit(JoiningStateForceLogout());
    await Globals.instance.hostSet(incomingHost);
    checkTokenAvailable(token, incomingHost);
  }

  Future<bool> _handleDifferenceServer() async {
    final authenticated = await Get.find<AuthenticationCubit>().isAuthenticated();
    if (authenticated) {
      final result = await Get.find<AuthenticationCubit>().logoutWithoutEmittingState();
      if(!result) {
        // back to normal authen flow if error occurs when logout with OIDC
        // (iOS has confirmation popup, user can cancel it)
        await Get.find<AuthenticationCubit>().checkAuthentication();
        return result;
      }
    }
    return true;
  }

  void checkTokenAvailable(String token, String incomingHost) async {
    emit(JoiningCheckTokenStart());
    try {
      final checkTokenResponse =
          await _repository.joinWorkspace(WorkspaceJoinRequest(false, token));
      emit(JoiningCheckTokenFinished(joinResponse: checkTokenResponse));
    } catch (e) {
      Logger().e('ERROR during checking magic link token:\n$e');
      emit(JoiningCheckTokenFinished(joinResponse: null));
    }
  }

  Future<WorkspaceJoinResponse?> joinWorkspace(
      String requestedToken,
      {required bool needCheckAuthentication}
  ) async {
    emit(InvitationJoinInit());
    try {
      final joinResponse = await _repository.joinWorkspace(WorkspaceJoinRequest(true, requestedToken));
      if(joinResponse != null) {
        emit(InvitationJoinSuccess(
            requestedToken: requestedToken,
            joinResponse: joinResponse,
            needCheckAuthentication: needCheckAuthentication));
        if(needCheckAuthentication) {
          await Get.find<AuthenticationCubit>().checkAuthentication(
            workspaceJoinResponse: joinResponse,
            pendingRequestedToken: requestedToken
          );
        }
      } else {
        emit(InvitationJoinFailed());
        // back to normal authen flow if joining failed
        await Get.find<AuthenticationCubit>().checkAuthentication(
            workspaceJoinResponse: null,
            pendingRequestedToken: requestedToken
        );
      }
      return joinResponse;
    } catch (e) {
      Logger().e('ERROR during joining workspace via magic link:\n$e');
      emit(InvitationJoinFailed());
      // back to normal authen flow if joining failed
      await Get.find<AuthenticationCubit>().checkAuthentication(
          workspaceJoinResponse: null,
          pendingRequestedToken: requestedToken
      );
      return null;
    }
  }

}