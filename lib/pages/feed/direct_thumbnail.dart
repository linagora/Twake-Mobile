import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/random_hex_color.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class DirectThumbnail extends StatelessWidget {
  final String userId;
  final double size;

  const DirectThumbnail({
    Key key,
    this.userId,
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userId != null && userId.isNotReallyEmpty) {
      return BlocProvider<UserBloc>(
        create: (_) => UserBloc(userId),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (_, state) {
            String thumbnailUrl;
            if (state is UserReady) {
              thumbnailUrl = state.thumbnail;
              if (thumbnailUrl != null && thumbnailUrl.isNotReallyEmpty) {
                return RoundedImage(
                  thumbnailUrl,
                  width: size,
                  height: size,
                );
              } else {
                String firstName = state.firstName;
                String firstNameLetter = '';
                if (firstName != null && firstName.isNotReallyEmpty) {
                  firstNameLetter = firstName[0];
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
                      '$firstNameLetter',
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
            } else {
              return RoundedShimmer(size: size);
            }
          },
        ),
      );
    } else {
      return RoundedShimmer(size: size);
    }
  }
}

class RoundedShimmer extends StatelessWidget {
  const RoundedShimmer({
    Key key,
    @required this.size,
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
