import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/profile_event.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/states/profile_state.dart';

export 'package:twake/events/profile_event.dart';
export 'package:twake/states/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  static ProfileBloc _profileBloc;

  factory ProfileBloc([ProfileRepository repository]) {
    if (_profileBloc == null) {
      _profileBloc = ProfileBloc._(repository);
    }
    return _profileBloc;
  }

  ProfileBloc._(this.repository)
      : super(ProfileLoaded(
          userId: repository.id,
          firstName: repository.firstName,
          lastName: repository.lastName,
          thumbnail: repository.thumbnail,
        ));

  bool isMe(String userId) => repository.id == userId;

  String get userId => repository.id;

  String get selectedCompany => repository.selectedCompanyId;
  String get selectedWorkspace => repository.selectedWorkspaceId;

  set selectedCompany(String val) {
    repository.selectedCompanyId = val;
    repository.save();
  }

  set selectedWorkspace(String val) {
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

  @override
  Future<void> close() {
    _profileBloc.close();
    return super.close();
  }
}
