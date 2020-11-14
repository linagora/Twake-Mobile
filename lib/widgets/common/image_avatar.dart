import 'package:flutter/material.dart';
// import 'package:mime/mime.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
// TODO image loading failes spantaneously, have to figure out solution
// But it definitely has to do with S3 storage

const String _FALLBACK_IMG = 'assets/images/1024x1024.png';

class ImageAvatar extends StatelessWidget {
  final String imageUrl;
  ImageAvatar(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    // final mime = lookupMimeType(imageUrl.split('/').last);
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        DimensionsConfig.widthMultiplier * 0.5,
      ),
      child: imageUrl == null
          ? onErrorFallbackImg()
          : FadeInImage.assetNetwork(
              image: imageUrl,
              width: DimensionsConfig.widthMultiplier * 8,
              height: DimensionsConfig.widthMultiplier * 8,
              placeholder: _FALLBACK_IMG,
              // headers: {
              // 'CONTENT-TYPE': mime,
              // 'ACCEPT':
              // 'image/png, image/jpeg, image/jpg, application/octet-stream'
              // },
            ),
    );
  }
}

Widget onErrorFallbackImg() => Image.asset(
      _FALLBACK_IMG,
      width: DimensionsConfig.widthMultiplier * 7,
      height: DimensionsConfig.widthMultiplier * 7,
    );

// 'https://lh3.googleusercontent.com/proxy/vVnrKCKFprDeQb4UqVOn_E_iK-BoUYb7BuV6p9hN0Vd9V3GbvTK8dOLyidagUGfHSaqmtlEt9DGUSt8fo4mCzXRthXJwJ8BFzUTpZ0bs2AM0quP6_bjzOOJHV9zytpQmtZG07Jxn',
