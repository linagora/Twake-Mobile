import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class SelectableAvatar extends StatelessWidget {
  final double size;
  final String icon;
  final String userPic;
  final String localAsset;
  final List<int> bytes;
  final Function onTap;

  const SelectableAvatar({
    Key? key,
    this.size = 48.0,
    this.icon = '',
    this.userPic = '',
    this.localAsset = '',
    required this.bytes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final userPic = this.userPic;
    final localAsset = this.localAsset;
    final bytes = Uint8List.fromList(this.bytes);

    return GestureDetector(
      onTap: onTap as void Function()?, // ?? _getImage(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        child: icon.isNotReallyEmpty
            ? Center(
                child: Text(
                  icon,
                  style: TextStyle(fontSize: Dim.tm3()),
                ),
              )
            : RoundedImage(
                imageUrl: userPic.isNotReallyEmpty ? userPic : '',
                assetPath: localAsset.isNotReallyEmpty ? localAsset : '',
                bytes: bytes,
                width: size,
                height: size,
              ),
      ),
    );
  }
}
