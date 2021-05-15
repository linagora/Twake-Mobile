import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/utils/extensions.dart';

const String _FALLBACK_IMG = 'assets/images/oldtwakelogo.jpg';

class RoundedImage extends StatelessWidget {
  final String imageUrl;
  final String assetPath;
  final Uint8List bytes;
  final double width;
  final double height;

  RoundedImage({
    this.imageUrl = '',
    this.assetPath = '',
    this.bytes,
    this.width = 30,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: width,
        height: height,
        child: imageUrl.isNotReallyEmpty
            ? CachedNetworkImage( // Loading from network.
                fit: BoxFit.cover,
                imageUrl: imageUrl,
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
              )
            : (assetPath.isNotReallyEmpty // Try to load from local path.
                ? Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  )
                : Image.memory( // Try to load from bytes array.
                    bytes ?? Uint8List(0),
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  )),
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
