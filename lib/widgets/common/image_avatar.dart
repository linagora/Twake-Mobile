import 'package:flutter/material.dart';

// import 'package:mime/mime.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

// TODO image loading failes spantaneously, have to figure out solution
// But it definitely has to do with S3 storage

const String _FALLBACK_IMG = 'assets/images/oldtwakelogo.jpg';

class ImageAvatar extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  ImageAvatar(
    this.imageUrl, {
    this.width = 30,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    // final mime = lookupMimeType(imageUrl.split('/').last);
    return ClipOval(
      child: imageUrl == null || imageUrl.isEmpty
          ? onErrorFallbackImg(width, height)
          : FadeInImage.assetNetwork(
              placeholderErrorBuilder: (_, f, l) => onErrorFallbackImg(
                width,
                height,
              ),
              fit: BoxFit.cover,
              image: imageUrl,
              width: width,
              height: height,
              placeholder: _FALLBACK_IMG,
            ),
    );
  }
}

Widget onErrorFallbackImg(double width, double height) {
  return Image.asset(
    _FALLBACK_IMG,
    // isAntiAlias: true,
    fit: BoxFit.cover,
    width: width,
    height: height,
  );
}

// 'https://lh3.googleusercontent.com/proxy/vVnrKCKFprDeQb4UqVOn_E_iK-BoUYb7BuV6p9hN0Vd9V3GbvTK8dOLyidagUGfHSaqmtlEt9DGUSt8fo4mCzXRthXJwJ8BFzUTpZ0bs2AM0quP6_bjzOOJHV9zytpQmtZG07Jxn',
