import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_event.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/blocs/profile_bloc/profile_state.dart';

export 'package:twake/blocs/profile_bloc/profile_event.dart';
export 'package:twake/blocs/profile_bloc/profile_state.dart';

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
  static String get firstName => repository.firstName;
  static String get lastName => repository.lastName;
  static String get thumbnail => repository.thumbnail;
  static String get username => repository.username;

  static String get selectedCompanyId => repository.selectedCompanyId;
  static String get selectedWorkspaceId => repository.selectedWorkspaceId;

  static String get selectedChannelId => repository.selectedChannelId;
  static String get selectedThreadId => repository.selectedThreadId;

  static Company get selectedCompany => repository.selectedCompany;
  static Workspace get selectedWorkspace => repository.selectedWorkspace;

  static set selectedCompanyId(String val) {
    repository.selectedCompanyId = val;
    repository.save();
  }

  static set selectedWorkspaceId(String val) {
    repository.selectedWorkspaceId = val;
    repository.save();
  }

  static set selectedChannelId(String val) {
    repository.selectedChannelId = val;
  }

  static set selectedThreadId(String val) {
    repository.selectedThreadId = val;
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
