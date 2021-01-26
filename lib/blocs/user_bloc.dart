import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/events/user_event.dart';
import 'package:twake/repositories/user_repository.dart';
import 'package:twake/states/user_state.dart';

export 'package:twake/events/user_event.dart';
export 'package:twake/states/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final repository = UserRepository();
  UserBloc(userId) : super(UserLoading()) {
    this.add(LoadUser(userId));
  }

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUser) {
      final user = await repository.user(event.userId);
      yield UserReady(
        thumbnail: user.thumbnail,
        username: user.username,
        lastName: user.lastName,
        firstName: user.firstName,
      );
    } else if (event is RemoveUser) {
      throw 'Not implemented yet';
    } else if (event is LoadUsers) {
      yield MultipleUsersLoading();
      final users = await repository.searchUsers(event.request);
      if (users != null) {
        yield MultipleUsersLoaded(users);
      } else {
        yield UserError('Users loading error.');
      }
    }
  }
}
