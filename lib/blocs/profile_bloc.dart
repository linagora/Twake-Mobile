import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/profile_event.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/states/profile_state.dart';

class AuthBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  AuthBloc(this.repository)
      : super(ProfileLoaded(
          userId: repository.userId,
          firstname: repository.firstName,
          lastname: repository.firstName,
          thumbnail: repository.thumbnail,
        ));

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ReloadProfile) {
      await repository.reload();
      yield ProfileLoaded(
        userId: repository.userId,
        firstname: repository.firstName,
        lastname: repository.firstName,
        thumbnail: repository.thumbnail,
      );
    } else if (event is ClearProfile) {
      await repository.clean();
      yield ProfileEmpty();
    }
  }
}
