import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/profile_event.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/states/profile_state.dart';

export 'package:twake/events/profile_event.dart';
export 'package:twake/states/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  ProfileBloc(this.repository)
      : super(ProfileLoaded(
          userId: repository.id,
          firstName: repository.firstName,
          lastName: repository.lastName,
          thumbnail: repository.thumbnail,
        ));

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
