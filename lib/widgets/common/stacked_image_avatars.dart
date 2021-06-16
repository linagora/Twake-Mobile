import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'image_avatar.dart';

class StackedUserAvatars extends StatelessWidget {
  final List<String> userIds;
  final double width;
  final double height;

  StackedUserAvatars({
    required this.userIds,
    this.width = 32,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (userIds.length == 0) return Container(width: width, height: height);

    List<Container> paddedAvatars = [];
    for (int i = 0; i < userIds.length; i++) {
      paddedAvatars.add(
        Container(
          width: width,
          height: height,
          child: FutureBuilder(
            future: Get.find<AccountCubit>().fetchStateless(userId: userIds[i]),
            builder: (context, snapshot) => ImageAvatar(
                snapshot.connectionState == ConnectionState.done
                    ? (snapshot.data as Account).thumbnail
                    : null),
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
