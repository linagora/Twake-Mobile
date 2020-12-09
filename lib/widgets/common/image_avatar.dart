import 'package:flutter/material.dart';
// import 'package:mime/mime.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
// TODO image loading failes spantaneously, have to figure out solution
// But it definitely has to do with S3 storage

const String _FALLBACK_IMG = 'assets/images/oldtwakelogo.jpg';

class ImageAvatar extends StatelessWidget {
  final String imageUrl;
  ImageAvatar(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    // final mime = lookupMimeType(imageUrl.split('/').last);
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        Dim.widthMultiplier * 0.5,
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? onErrorFallbackImg()
          : FadeInImage.assetNetwork(
              fit: BoxFit.cover,
              image: imageUrl,
              width: Dim.hm5,
              height: Dim.hm5,
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
      // isAntiAlias: true,
      fit: BoxFit.cover,
      width: Dim.hm5,
      height: Dim.hm5,
    );

// 'https://lh3.googleusercontent.com/proxy/vVnrKCKFprDeQb4UqVOn_E_iK-BoUYb7BuV6p9hN0Vd9V3GbvTK8dOLyidagUGfHSaqmtlEt9DGUSt8fo4mCzXRthXJwJ8BFzUTpZ0bs2AM0quP6_bjzOOJHV9zytpQmtZG07Jxn',
