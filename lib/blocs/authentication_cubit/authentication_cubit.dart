import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/sync_data_state.dart';
import 'package:twake/blocs/magic_link_cubit/joining_cubit/joining_cubit.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/twakelink/twake_link_joining.dart';
import 'package:twake/repositories/authentication_repository.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/twake_exception.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  late final AuthenticationRepository _repository;
  late final StreamSubscription _networkSubscription;
  final InitService _initService = Get.find<InitService>();

  AuthenticationCubit({AuthenticationRepository? repository})
      : super(AuthenticationInitial()) {
    if (repository == null) {
      repository = AuthenticationRepository();
    }

    _repository = repository;

    _networkSubscription = Globals.instance.connection.listen((connection) {
      if (connection == Connection.connected) _repository.startTokenValidator();
    });
  }

  Future<void> checkAuthentication({
    WorkspaceJoinResponse? workspaceJoinResponse,
    String? pendingRequestedToken,
    TwakeLinkJoining? twakeLinkJoining,
  }) async {
    emit(AuthenticationInProgress());
    bool authenticated = await _repository.isAuthenticated();

    if (authenticated) {
      emit(AuthenticationSuccess(
        magicLinkJoinResponse: workspaceJoinResponse,
        twakeLinkJoining: twakeLinkJoining,
      ));
      _repository.startTokenValidator();
      await NavigatorService.instance.navigateOnNotificationLaunch();
    } else if(workspaceJoinResponse != null) {
      emit(AuthenticationInvitationPending(requestedToken: pendingRequestedToken));
    } else {
      emit(AuthenticationInitial());
    }
    Globals.instance.handlingMagicLink = false;
  }

  Future<void> refetchAllAfterRetriedNoCompany({WorkspaceJoinResponse? joinResponse}) async {
    await syncData(magicLinkJoinResponse: joinResponse);
  }

  Future<bool> authenticate({String? requestedMagicLinkToken}) async {
    emit(AuthenticationInProgress());
    final authenticated = await _repository.webviewAuthenticate();
    if (authenticated) {
      if(requestedMagicLinkToken != null && requestedMagicLinkToken.isNotEmpty) {
        final joinResponse = await Get.find<JoiningCubit>().joinWorkspace(requestedMagicLinkToken, needCheckAuthentication: false);
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

    try {
      final progress = _initService.syncData();
      await for (final p in progress) {
        Logger().i("Sync data: $p");
        if(p is SyncDataSuccessState) {
          emit(PostAuthenticationSyncInProgress(progress: p.process));
        } else if(p is SyncDataFailState) {
          emit(PostAuthenticationSyncFailedSomeServices(syncFailedSource: p.failedSource));
        }
      }
      emit(PostAuthenticationSyncSuccess(magicLinkJoinResponse: magicLinkJoinResponse));
    } catch (e, stt) {
      Logger().e('Error occurred during initial data sync:\n$e\n$stt');
      if(e is SyncFailedException) {
        emit(PostAuthenticationSyncFailedSomeServices(syncFailedSource: e.failedSource));
      } else {
        emit(PostAuthenticationSyncFailed());
      }
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

  Future<bool> logoutWithoutEmittingState() async {
    try {
      await _repository.logout();
      SocketIOService.instance.disconnect();
      return true;
    } catch (e) {
      Logger().e('Error occurred during logout:\n$e');
      return false;
    }
  }

  void registerDevice() async {
    await _repository.registerDevice();
  }

  void unRegisterDevice() async {
    await _repository.registerDevice();
  }

  void joiningWithMagicLink(String token, {required String incomingHost}) async {
    Globals.instance.handlingMagicLink = true;
    emit(JoiningMagicLinkState(
      requestedToken: token,
      incomingHost: incomingHost,
    ));
  }

  Future<bool> isAuthenticated() async => await _repository.isAuthenticated();

  Future<void> resetAuthenticationState() async {
    emit(AuthenticationInitial());
  }

  Future<void> notifyNoCompanyBelongToUser({WorkspaceJoinResponse? magicLinkJoinResponse}) async {
    emit(PostAuthenticationNoCompanyFound(magicLinkJoinResponse: magicLinkJoinResponse));
  }

  @override
  Future<void> close() {
    _networkSubscription.cancel();
    return super.close();
  }
}
