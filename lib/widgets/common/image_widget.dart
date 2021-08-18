import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/rounded_shimmer.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

const String _FALLBACK_IMG = 'assets/images/oldtwakelogo.jpg';

class ImageWidget extends StatelessWidget {
  final isPrivate;
  final String? imageUrl;
  final ImageType imageType;
  final String name;
  final double size;
  final Color backgroundColor;
  final double borderRadius;
  const ImageWidget(
      {Key? key,
      this.size = 0,
      this.imageUrl = "",
      required this.imageType,
      this.isPrivate = false,
      this.name = "",
      this.borderRadius = 0,
      this.backgroundColor = Colors.transparent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageType == ImageType.channel) {
      if (imageUrl != null && imageUrl != "") {
        return channelImage(imageUrl, isPrivate);
      } else
        return namedAvatar(name, size, backgroundColor);
    }
    if (imageType == ImageType.direct) {
      if (imageUrl != null && imageUrl != "") {
        return roundImage(imageUrl, isPrivate, size, borderRadius);
      } else
        return namedAvatar(name, size, backgroundColor);
    }
    if (imageType == ImageType.chat) {
      if (imageUrl != null && imageUrl != "") {
        return roundImage(imageUrl, isPrivate, size, borderRadius);
      } else {
        return namedAvatar(name, size, backgroundColor);
      }
    }
    if (imageType == ImageType.workspace) {
      if (name != "") {
        return namedAvatar(name, size, backgroundColor);
      } else {
        return RoundedShimmer(size: size);
      }
    }
    if (imageType == ImageType.homeDrower) {
      if (imageUrl != null && imageUrl != "") {
        return roundImage(imageUrl, isPrivate, size, borderRadius);
      } else {
        return RoundedShimmer(size: size);
      }
    }
    return RoundedShimmer(size: size);
  }

  Widget roundImage(
      String? imageUrl, bool isPrivate, double size, double borderRadius) {
    if (imageUrl == null) {
      imageUrl = "";
    }

    imageUrl = imageUrl.contains('http')
        ? imageUrl
        : Globals.instance.host + "/$imageUrl";
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius == 0
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(borderRadius),
        border: Border.all(
          style: BorderStyle.solid,
          width: 0,
          color: Colors.transparent,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius == 0
            ? BorderRadius.circular(size / 2 - 1)
            : BorderRadius.circular(borderRadius),
        child: Container(
            width: size,
            height: size,
            child: CachedNetworkImage(
              // Loading from network.
              fit: BoxFit.cover,
              imageUrl: imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return ShimmerLoading(
                  isLoading: true,
                  width: size,
                  height: size,
                  child: Container(),
                );
              },
              errorWidget: (context, url, error) {
                return Image.asset(
                  _FALLBACK_IMG,
                  // isAntiAlias: true,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                );
              },
            )),
      ),
    );
  }

  Widget channelImage(String? icon, bool isPrivate) {
    if (icon == null) {
      icon = "";
    }
    return Stack(alignment: Alignment.topRight, children: [
      Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xfff5f5f5),
        ),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(46 * 0.5),
          ),
          child: AutoSizeText(
            icon,
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
      if (isPrivate) Image.asset('assets/images/private.png'),
    ]);
  }

  Widget namedAvatar(String name, double size, Color backgroundColor) {
    String charactersToShow = '';
    if (name.isNotReallyEmpty) {
      charactersToShow = name[0].toUpperCase();

      final splitWords = name.split(' ');
      if (splitWords.length > 1) {
        final secondWord = splitWords[1];
        if (secondWord.isNotReallyEmpty) {
          charactersToShow =
              '$charactersToShow${splitWords[1][0].toUpperCase()}';
        }
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: backgroundColor == Colors.transparent
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: userColors(),
              ), // TODO: del old randomGradient()?,
            )
          : BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
      padding: EdgeInsets.all(5.0),
      alignment: Alignment.center,
      child: SizedBox.expand(
        child: FittedBox(
          child: Text(
            charactersToShow,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: backgroundColor == Colors.transparent
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> userColors() {
    return [
      HSLColor.fromAHSL(1, name.hashCode % 360, 0.9, 0.7).toColor(),
      HSLColor.fromAHSL(
              1, (name.hashCode % 360 - 60).toDouble().abs(), 0.9, 0.7)
          .toColor()
    ];
  }
}

enum ImageType { channel, direct, chat, workspace, homeDrower, none }