import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DropDownButton extends StatelessWidget {
  final bool isTop;
  final bool isBottom;
  final bool isSecondBottom;
  final String text;

  /// if don't have icon, provide imagePath
  final String? imagePath;
  final Color? backgroundColor;
  final Color? textColor;
  final Function() onClick;
  final IconData? icon;
  final Color? iconColor;

  static const double DROPDOWN_WIDTH = 254;
  static const double DROPDOWN_HEIGHT = 44;
  static const double DROPDOWN_PADDING_TOP = 10;
  static const double DROPDOWN_PADDING_LEFT = 11;
  static const double DROPDOWN_TOP_LAST_ITEM_PADDING_HEIGHT = 8;
  static const double DROPDOWN_SEPARATOR_HEIGHT = 1;

  const DropDownButton({
    required this.onClick,
    required this.text,
    this.imagePath,
    this.isBottom = false,
    this.isTop = false,
    this.isSecondBottom = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (isBottom) ...[
        Container(
          height: DROPDOWN_TOP_LAST_ITEM_PADDING_HEIGHT,
          width: DropDownButton.DROPDOWN_WIDTH,
          color: Color(0x14141426),
        )
      ],
      InkWell(
        onTap: () => onClick(),
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor ?? Theme.of(context).primaryColor,
              borderRadius: isTop
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0))
                  : (isBottom
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))
                      : null)),
          width: DROPDOWN_WIDTH,
          height: DROPDOWN_HEIGHT,
          padding: const EdgeInsets.fromLTRB(
              DROPDOWN_PADDING_LEFT,
              DROPDOWN_PADDING_TOP,
              DROPDOWN_PADDING_LEFT,
              DROPDOWN_PADDING_TOP),
          child: Row(children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: textColor),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                imagePath == null
                    ? Icon(
                        icon,
                        color: iconColor ?? Theme.of(context).iconTheme.color,
                      )
                    : imagePath!.endsWith("png")
                        ? Image.asset(
                            imagePath!,
                            fit: BoxFit.fitHeight,
                            height: 18,
                            color: Theme.of(context).iconTheme.color,
                          )
                        : SvgPicture.asset(
                            imagePath!,
                            fit: BoxFit.fitHeight,
                            height: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
              ],
            ),
          ]),
        ),
      ),
      Container(
          color: isBottom || isSecondBottom
              ? null
              : Theme.of(context).colorScheme.secondary,
          height: DROPDOWN_SEPARATOR_HEIGHT,
          width: DROPDOWN_WIDTH),
    ]);
  }
}
