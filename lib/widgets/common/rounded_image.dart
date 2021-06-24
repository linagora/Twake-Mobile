import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/utils/extensions.dart';

const String _FALLBACK_IMG = 'assets/images/oldtwakelogo.jpg';

class RoundedImage extends StatelessWidget {
  final String assetPath;
  final Uint8List? bytes;
  final double width;
  final double height;
  final bool isSelected;
  final double borderWidth;
  final double borderRadius;
  final String imageUrl;

  RoundedImage({
    this.assetPath = '',
    this.bytes,
    this.width = 30.0,
    this.height = 30.0,
    this.isSelected = false,
    this.borderWidth = 0.0,
    this.borderRadius = 0.0,
    final imageUrl = '',
  }) : this.imageUrl = imageUrl.contains('http')
            ? imageUrl
            : Globals.instance.host + "/$imageUrl";

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius != 0 ? borderRadius : width / 2;

    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(borderWidth / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          style: BorderStyle.solid,
          width: borderWidth,
          color: isSelected ? Color(0xff004dff) : Colors.transparent,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Container(
          width: width - 2 * borderWidth,
          height: height - 2 * borderWidth,
          child: imageUrl.isNotReallyEmpty
              ? CachedNetworkImage(
                  // Loading from network.
                  fit: BoxFit.cover,
                  imageUrl: imageUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return ShimmerLoading(
                      isLoading: true,
                      width: width - 2 * borderWidth,
                      height: height - 2 * borderWidth,
                      child: Container(),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return _onErrorFallbackImg(width, height);
                  },
                )
              : assetPath.isNotReallyEmpty // Try to load from local path.
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      // Try to load from bytes array.
                      bytes ?? Uint8List(0),
                      fit: BoxFit.cover,
                    ),
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
