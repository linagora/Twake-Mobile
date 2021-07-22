import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/named_avatar.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/rounded_shimmer.dart';

class UserThumbnail extends StatelessWidget {
  final String userId;
  final String thumbnailUrl;
  final String userName;
  final double size;

  const UserThumbnail({
    Key? key,
    this.userId = '',
    this.thumbnailUrl = '',
    this.userName = '',
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userId.isNotReallyEmpty) {
      return BlocProvider<AccountCubit>(
        create: (_) => AccountCubit(),
        child: BlocBuilder<AccountCubit, AccountState>(
          builder: (_, state) {
            var thumbUrl;
            if (state is AccountLoadSuccess) {
              thumbUrl = state.account.picture ?? '';
              if (thumbnailUrl.isNotReallyEmpty) {
                return RoundedImage(
                  imageUrl: thumbUrl,
                  width: size,
                  height: size,
                );
              } else {
                return NamedAvatar(size: size, name: state.account.fullName);
              }
            } else {
              return RoundedShimmer(size: size);
            }
          },
        ),
      );
    } else if (thumbnailUrl.isNotReallyEmpty) {
      return RoundedImage(
        imageUrl: thumbnailUrl,
        width: size,
        height: size,
      );
    } else if (userName.isNotReallyEmpty) {
      return NamedAvatar(size: size, name: userName);
    } else {
      return RoundedShimmer(size: size);
    }
  }
}
