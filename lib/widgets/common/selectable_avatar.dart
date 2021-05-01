import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class SelectableAvatar extends StatefulWidget {
  final double size;
  final Color backgroundColor;
  final String icon;
  final String userpic;
  final String localAsset;
  final Function onTap;

  const SelectableAvatar({
    Key key,
    this.size = 48.0,
    this.backgroundColor,
    this.icon,
    this.userpic,
    this.localAsset = 'assets/images/pic.png',
    this.onTap,
  }) : super(key: key);

  @override
  _SelectableAvatarState createState() => _SelectableAvatarState();
}

class _SelectableAvatarState extends State<SelectableAvatar> {
  final picker = ImagePicker();

  String _userpic;
  String _localAsset;
  String _icon;

  @override
  void initState() {
    super.initState();
    _userpic = widget.userpic;
    _localAsset = widget.localAsset;
    _icon = widget.icon;
  }

  @override
  void didUpdateWidget(covariant SelectableAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userpic != widget.userpic) {
      _userpic = widget.userpic;
    }
    if (oldWidget.icon != widget.icon) {
      _icon = widget.icon;
    }
    if (oldWidget.localAsset != widget.localAsset) {
      _localAsset = widget.localAsset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // ?? _getImage(),
      behavior: HitTestBehavior.opaque,
      child: Container(
          width: widget.size,
          height: widget.size,
          child: (_icon != null && _icon.isNotReallyEmpty)
              ? Center(
                  child: Text(
                    _icon,
                    style: TextStyle(fontSize: Dim.tm3()),
                  ),
                )
              : RoundedImage(
                  imageUrl: (_userpic != null && _userpic.isNotReallyEmpty)
                      ? _userpic
                      : '',
                  assetPath:
                      (_localAsset != null && _localAsset.isNotReallyEmpty)
                          ? _localAsset
                          : '',
                  width: widget.size,
                  height: widget.size,
                )

          // decoration: _bytes != null
          //     ? BoxDecoration(
          //         shape: BoxShape.circle,
          //         image: DecorationImage(
          //           image: MemoryImage(
          //             _bytes,
          //           ),
          //           fit: BoxFit.fill,
          //         ),
          //       )
          //     : BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: widget.backgroundColor ?? Color(0xffe3e3e3),
          //       ),
          ),
    );
  }
}
