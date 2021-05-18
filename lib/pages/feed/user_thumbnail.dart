import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/random_hex_color.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class UserThumbnail extends StatelessWidget {
  final String? userId;
  final String? thumbnailUrl;
  final String? userName;
  final double size;

  const UserThumbnail({
    Key? key,
    this.userId,
    this.thumbnailUrl,
    this.userName,
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userId != null && userId!.isNotReallyEmpty) {
      return BlocProvider<UserBloc>(
        create: (_) => UserBloc(userId),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (_, state) {
            String? thumbnailUrl;
            if (state is UserReady) {
              thumbnailUrl = state.thumbnail;
              if (thumbnailUrl != null && thumbnailUrl.isNotReallyEmpty) {
                return RoundedImage(
                  imageUrl: thumbnailUrl,
                  width: size,
                  height: size,
                );
              } else {
                return NamedAvatar(size: size, name: state.firstName);
              }
            } else {
              return RoundedShimmer(size: size);
            }
          },
        ),
      );
    } else if (thumbnailUrl != null && thumbnailUrl!.isNotReallyEmpty) {
      return RoundedImage(
        imageUrl: thumbnailUrl,
        width: size,
        height: size,
      );
    } else if (userName != null && userName!.isNotReallyEmpty) {
      return NamedAvatar(size: size, name: userName);
    } else {
      return RoundedShimmer(size: size);
    }
  }
}

class NamedAvatar extends StatelessWidget {
  const NamedAvatar({
    Key? key,
    this.size = 60.0,
    this.name = '',
  }) : super(key: key);

  final double size;
  final String? name;

  @override
  Widget build(BuildContext context) {
    String firstNameCharacter = '';
    if (name!.isNotReallyEmpty) {
      firstNameCharacter = name![0];
    }

    return CircleAvatar(
      radius: size / 2,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: randomGradient(),
        ),
        alignment: Alignment.center,
        child: Text(
          firstNameCharacter,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class RoundedShimmer extends StatelessWidget {
  const RoundedShimmer({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ShimmerLoading(
        isLoading: true,
        width: size,
        height: size,
        child: SizedBox(),
      ),
    );
  }
}
