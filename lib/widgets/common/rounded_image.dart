import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

const String _FALLBACK_IMG = 'assets/images/oldtwakelogo.jpg';

class RoundedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  RoundedImage(
    this.imageUrl, {
    this.width = 30,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: width,
        height: height,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: imageUrl == null ? '' : imageUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return ShimmerLoading(
              isLoading: true,
              width: width,
              height: height,
              child: Container(),
            );
          },
          errorWidget: (context, url, error) {
            return _onErrorFallbackImg(width, height);
          },
        ),
      ),
    );
  }
}

Widget _onErrorFallbackImg(double width, double height) {
  return Image.asset(
    _FALLBACK_IMG,
    // isAntiAlias: true,
    fit: BoxFit.cover,
    width: width,
    height: height,
  );
}
