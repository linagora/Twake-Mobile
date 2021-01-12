import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/profile_event.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/states/profile_state.dart';

export 'package:twake/events/profile_event.dart';
export 'package:twake/states/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static ProfileRepository repository;

  ProfileBloc(ProfileRepository rpstr)
      : super(ProfileLoaded(
          userId: rpstr.id,
          firstName: rpstr.firstName,
          lastName: rpstr.lastName,
          thumbnail: rpstr.thumbnail,
        )) {
    repository = rpstr;
  }

  bool isMe(String userId) => repository.id == userId;

  static String get userId => repository.id;

  static String get selectedCompany => repository.selectedCompanyId;
  static String get selectedWorkspace => repository.selectedWorkspaceId;

  static set selectedCompany(String val) {
    repository.selectedCompanyId = val;
    repository.save();
  }

  static set selectedWorkspace(String val) {
    repository.selectedWorkspaceId = val;
    repository.save();
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ReloadProfile) {
      await repository.reload();
      yield ProfileLoaded(
        userId: repository.id,
        firstName: repository.firstName,
        lastName: repository.lastName,
        thumbnail: repository.thumbnail,
      );
    } else if (event is ClearProfile) {
      await repository.clean();
      yield ProfileEmpty();
    }
  }
}
