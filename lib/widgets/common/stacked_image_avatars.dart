import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/user_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'image_avatar.dart';

class StackedUserAvatars extends StatelessWidget {
  final List<String> userIds;

  StackedUserAvatars(this.userIds);

  @override
  Widget build(BuildContext context) {
    List<Container> paddedAvatars = [];
    for (int i = 0; i < userIds.length; i++) {
      paddedAvatars.add(
        Container(
          width: 30,
          height: 30,
          child: BlocProvider<UserBloc>(
            create: (_) => UserBloc(userIds[i]),
            child: BlocBuilder<UserBloc, UserState>(builder: (ctx, state) {
              return ImageAvatar(
                state is UserReady ? state.thumbnail : null,
              );
            }),
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.centerLeft,
      children: paddedAvatars,
    );
  }
}
