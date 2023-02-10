import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropDownButton extends StatelessWidget {
  final bool isTop;
  final bool isBottom;
  final bool isSecondBottom;
  final String text;
  final String imagePath;
  final Color? backgroundColor;
  final Color? textColor;
  final Function() onClick;
  final Color? iconColor;

  static const double DROPDOWN_WIDTH = 254;
  static const double DROPDOWN_HEIGHT = 44;
  static const double DROPDOWN_PADDING_TOP = 10;
  static const double DROPDOWN_PADDING_LEFT = 11;
  static const double DROPDOWN_TOP_LAST_ITEM_PADDING_HEIGHT = 8;
  static const double DROPDOWN_SEPARATOR_HEIGHT = 0.5;

  const DropDownButton({
    required this.onClick,
    required this.text,
    required this.imagePath,
    this.isBottom = false,
    this.isTop = false,
    this.isSecondBottom = false,
    this.backgroundColor,
    this.textColor = Colors.black,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (isBottom) ...[
        Container(
          color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.25),
          height: DROPDOWN_TOP_LAST_ITEM_PADDING_HEIGHT,
          width: DropDownButton.DROPDOWN_WIDTH,
        )
      ],
      InkWell(
        onTap: () => onClick(),
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor ??
                  (Get.isDarkMode
                      ? Theme.of(context).primaryColor.withOpacity(0.7)
                      : Theme.of(context).cardColor),
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
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontSize: 17,
                ),
              ),
            ),
            Image.asset(
              imagePath,
              height: 20,
              width: 20,
              color: Get.isDarkMode ? Colors.white : null,
            ),
          ]),
        ),
      ),
      Container(
          color: isBottom || isSecondBottom
              ? null
              : Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.25),
          height: DROPDOWN_SEPARATOR_HEIGHT,
          width: DROPDOWN_WIDTH),
    ]);
  }
}
