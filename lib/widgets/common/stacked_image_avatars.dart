import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'image_avatar.dart';

class StackedUserAvatars extends StatelessWidget {
  final List<String>? userIds;
  final double width;
  final double height;

  StackedUserAvatars(
    this.userIds, {
    this.width = 32,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (userIds!.length == 0) return Container(width: width, height: height);

    List<Container> paddedAvatars = [];
    for (int i = 0; i < userIds!.length; i++) {
      paddedAvatars.add(
        Container(
          width: width,
          height: height,
          child: BlocProvider<UserBloc>(
            create: (_) => UserBloc(userIds![i]),
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
