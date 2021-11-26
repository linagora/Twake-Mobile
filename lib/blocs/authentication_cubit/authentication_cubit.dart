import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/deeplink/join/workspace_join_request.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/authentication_repository.dart';
import 'package:twake/repositories/magic_link_repository.dart';
import 'package:twake/services/service_bundle.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  late final AuthenticationRepository _repository;
  late final StreamSubscription _networkSubscription;
  late final MagicLinkRepository _magicLinkRepository;

  AuthenticationCubit({AuthenticationRepository? repository, MagicLinkRepository? magicLinkRepository})
      : super(AuthenticationInitial()) {
    if (repository == null) {
      repository = AuthenticationRepository();
    }

    _repository = repository;

    _networkSubscription = Globals.instance.connection.listen((connection) {
      if (connection == Connection.connected) _repository.startTokenValidator();
    });

    if (magicLinkRepository == null) {
      magicLinkRepository = MagicLinkRepository();
    }
    _magicLinkRepository = magicLinkRepository;
  }

  Future<void> checkAuthentication({WorkspaceJoinResponse? workspaceJoinResponse, String? pendingRequestedToken}) async {
    emit(AuthenticationInProgress());
    bool authenticated = await _repository.isAuthenticated();

    if (authenticated) {
      emit(AuthenticationSuccess(magicLinkJoinResponse: workspaceJoinResponse));
      _repository.startTokenValidator();
      await NavigatorService.instance.navigateOnNotificationLaunch();
    } else if(workspaceJoinResponse != null) {
      emit(AuthenticationInvitationPending(requestedToken: pendingRequestedToken));
    } else {
      emit(AuthenticationInitial());
    }
  }

  Future<bool> authenticate({String? requestedMagicLinkToken}) async {
    emit(AuthenticationInProgress());
    final authenticated = await _repository.webviewAuthenticate();
    if (authenticated) {
      if(requestedMagicLinkToken != null && requestedMagicLinkToken.isNotEmpty) {
        final joinResponse = await joinWorkspace(requestedMagicLinkToken, needCheckAuthentication: false);
        _repository.startTokenValidator();
        SocketIOService.instance.connect();
        await syncData(magicLinkJoinResponse: joinResponse);
        emit(AuthenticationSuccess(magicLinkJoinResponse: joinResponse));
      } else {
        emit(AuthenticationSuccess());
        _repository.startTokenValidator();
        SocketIOService.instance.connect();
        await syncData();
      }
    } else {
      emit(AuthenticationInitial());
    }
    return authenticated;
  }

  Future<void> syncData({WorkspaceJoinResponse? magicLinkJoinResponse}) async {
    emit(PostAuthenticationSyncInProgress(progress: 0));

    final start = DateTime.now();

    final progress = InitService.syncData();

    try {
      await for (final p in progress) {
        emit(PostAuthenticationSyncInProgress(progress: p));
      }

      emit(PostAuthenticationSyncSuccess(magicLinkJoinResponse: magicLinkJoinResponse));
    } catch (e, stt) {
      Logger().e('Error occurred during initial data sync:\n$e\n$stt');
      emit(PostAuthenticationSyncFailed());
    }

    final end = DateTime.now();
    Logger().v('SYNC TOOK: ${end.difference(start).inSeconds} sec');
  }

  void logout() async {
    emit(LogoutInProgress());
    await _repository.logout();
    SocketIOService.instance.disconnect();
    emit(AuthenticationInitial());
  }

  void registerDevice() async {
    await _repository.registerDevice();
  }

  void unRegisterDevice() async {
    await _repository.registerDevice();
  }

  void checkTokenAvailable(String token) async {
    emit(InvitationJoinCheckingInit());
    try {
      final checkTokenResponse = await _magicLinkRepository.joinWorkspace(WorkspaceJoinRequest(false, token));
      emit(InvitationJoinCheckingTokenFinished(joinResponse: checkTokenResponse, requestedToken: token));
    } catch (e) {
      Logger().e('ERROR during checking magic link token:\n$e');
      emit(InvitationJoinCheckingTokenFinished(joinResponse: null, requestedToken: token));
    }
  }

  Future<WorkspaceJoinResponse?> joinWorkspace(String requestedToken, {required bool needCheckAuthentication}) async {
    emit(InvitationJoinInit());
    try {
      final joinResponse = await _magicLinkRepository.joinWorkspace(WorkspaceJoinRequest(true, requestedToken));
      if(joinResponse != null) {
        emit(InvitationJoinSuccess(
            requestedToken: requestedToken,
            joinResponse: joinResponse,
            needCheckAuthentication: needCheckAuthentication));
      } else {
        emit(InvitationJoinFailed());
      }
      return joinResponse;
    } catch (e) {
      Logger().e('ERROR during joining workspace via magic link:\n$e');
      emit(InvitationJoinFailed());
      return null;
    }
  }

  @override
  Future<void> close() {
    _networkSubscription.cancel();
    return super.close();
  }
}
