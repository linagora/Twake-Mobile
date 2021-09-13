import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twake/models/channel/channel.dart';
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
  final List<Avatar> avatars;
  final double stackSize;
  const ImageWidget(
      {Key? key,
      this.size = 0,
      this.imageUrl = "",
      required this.imageType,
      this.isPrivate = false,
      this.name = "",
      this.borderRadius = 0,
      this.avatars = const [],
      this.stackSize = 35,
      this.backgroundColor = Colors.transparent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageType == ImageType.channel) {
      if (imageUrl != null && imageUrl != "") {
        return channelImage(imageUrl, isPrivate);
      } else
        return namedAvatar(name, size, backgroundColor, borderRadius);
    }
    if (imageType == ImageType.common) {
      if (imageUrl != null &&
          imageUrl != "" &&
          (avatars.length == 1 || avatars.isEmpty)) {
        return roundImage(imageUrl, isPrivate, size, borderRadius);
      } else if (avatars.isNotEmpty && imageUrl != "") {
        return stackImage(stackSize, avatars, borderRadius, backgroundColor);
      } else
        return namedAvatar(name, size, backgroundColor, borderRadius);
    }

    return RoundedShimmer(size: size);
  }

  Widget stackImage(double stackSize, List<Avatar> avatars, double borderRadius,
      Color backgroundColor) {
    List<Widget> imageAvatars = [];

    final len = avatars.length > 2 ? 2 : avatars.length;
    for (int i = 0; i < len; i++) {
      if (avatars[i].link != "") {
        imageAvatars.add(
          Positioned(
            left: i * stackSize / 2,
            child:
                roundImage(avatars[i].link, isPrivate, stackSize, borderRadius),
          ),
        );
      } else {
        imageAvatars.add(
          Positioned(
            left: i * stackSize / 2,
            child: namedAvatar(
                avatars[i].name, stackSize, backgroundColor, borderRadius),
          ),
        );
      }
    }

    return Center(
      child: Container(
        height: size,
        width: size,
        child: Stack(
          children: imageAvatars,
        ),
      ),
    );
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
          width: 2,
          color: Colors.grey.shade300,
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
              return namedAvatar(name, size, backgroundColor, borderRadius);
            },
          ),
        ),
      ),
    );
  }

  Widget channelImage(String? icon, bool isPrivate) {
    if (icon == null) {
      icon = "";
    }
    return Stack(alignment: Alignment.topRight, children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xfff5f5f5),
        ),
        child: Container(
          width: size - 10,
          height: size - 10,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.5),
          ),
          child: AutoSizeText(
            icon,
            style: TextStyle(fontSize: size * 0.6),
          ),
        ),
      ),
      if (isPrivate) Image.asset('assets/images/private.png'),
    ]);
  }

  Widget namedAvatar(
      String name, double size, Color backgroundColor, double borderRadius) {
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

    return ClipRRect(
      borderRadius: borderRadius == 0
          ? BorderRadius.circular(size / 2 - 1)
          : BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: backgroundColor == Colors.transparent
            ? BoxDecoration(
                shape: borderRadius == 0 ? BoxShape.circle : BoxShape.rectangle,
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 2,
                  color: Colors.grey.shade300,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: userColors(),
                ), // TODO: del old randomGradient()?,
              )
            : BoxDecoration(
                shape: borderRadius == 0 ? BoxShape.circle : BoxShape.rectangle,
                color: backgroundColor,
              ),
        padding: EdgeInsets.all(5.0),
        alignment: Alignment.center,
        child: SizedBox.expand(
          child: FittedBox(
            fit: backgroundColor == Colors.transparent
                ? BoxFit.contain
                : BoxFit.none,
            child: Text(
              charactersToShow,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: backgroundColor == Colors.transparent ? 26 : 20,
                fontWeight: FontWeight.bold,
                color: backgroundColor == Colors.transparent
                    ? Colors.white
                    : Colors.black,
              ),
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

enum ImageType { common, channel, none }
