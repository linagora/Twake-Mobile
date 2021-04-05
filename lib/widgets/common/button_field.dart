import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonField extends StatelessWidget {
  final String title;
  final String trailingTitle;
  final String image;
  final bool hasArrow;
  final bool isRounded;
  final Widget trailingWidget;
  final Function onTap;
  final double height;
  final TextStyle titleStyle;
  final Color arrowColor;
  final TextStyle trailingTitleStyle;

  const ButtonField({
    Key key,
    @required this.title,
    this.image,
    this.trailingTitle,
    this.hasArrow = false,
    this.isRounded = true,
    this.trailingWidget,
    this.onTap,
    this.height = 44,
    this.titleStyle,
    this.arrowColor,
    this.trailingTitleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              isRounded ? BorderRadius.circular(10.0) : BorderRadius.zero,
        ),
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 14),
            if (image != null && image.isNotEmpty)
              SizedBox(
                width: 29.0,
                height: 29.0,
                child: Image.asset(image),
              ),
            Text(
              title,
              style: titleStyle ??
                  TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
            ),
            Spacer(),
            if (trailingWidget == null)
              hasArrow
                  ? Row(
                      children: [
                        if (trailingTitle != null)
                          Text(
                            trailingTitle,
                            style: trailingTitleStyle ??
                                TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff3840F7),
                                ),
                          ),
                        Icon(
                          CupertinoIcons.forward,
                          color: arrowColor ?? Color(0xff3840F7),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 9.0),
                      child: Text(
                        trailingTitle,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff3840F7),
                        ),
                      ),
                    ),
            if (trailingWidget != null) trailingWidget,
            SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
