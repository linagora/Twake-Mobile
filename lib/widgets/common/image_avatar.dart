import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
// TODO image loading failes spantaneously, have to figure out solution
// But it definitely has to do with S3 storage

const String _FALLBACK_IMG = 'assets/images/empty-image.png';

class ImageAvatar extends StatelessWidget {
  final String imageUrl;
  ImageAvatar(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final mime = lookupMimeType(imageUrl.split('/').last);
    final insecure = imageUrl.replaceFirst('https', 'http');
    print(insecure);
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        DimensionsConfig.widthMultiplier * 0.5,
      ),
      child: imageUrl == null
          ? onErrorFallbackImg()
          : Image.network(
              insecure,
              // 'https://lh3.googleusercontent.com/proxy/vVnrKCKFprDeQb4UqVOn_E_iK-BoUYb7BuV6p9hN0Vd9V3GbvTK8dOLyidagUGfHSaqmtlEt9DGUSt8fo4mCzXRthXJwJ8BFzUTpZ0bs2AM0quP6_bjzOOJHV9zytpQmtZG07Jxn',
              width: DimensionsConfig.widthMultiplier * 8,
              height: DimensionsConfig.widthMultiplier * 8,
              errorBuilder: (ctx, obj, _) => onErrorFallbackImg(),
              headers: {
                'CONTENT-TYPE': mime,
                'ACCEPT':
                    'image/png, image/jpeg, image/jpg, application/octet-stream'
              },
            ),
    );
  }
}

Widget onErrorFallbackImg() => Image.asset(
      _FALLBACK_IMG,
      width: DimensionsConfig.widthMultiplier * 7,
      height: DimensionsConfig.widthMultiplier * 7,
    );
