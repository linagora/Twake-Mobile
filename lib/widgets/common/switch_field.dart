import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/common/button_field.dart';

class SwitchField extends StatelessWidget {
  final String? image;
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final bool isExtended;
  final bool isRounded;
  final BorderRadius borderRadius;
  final TextStyle? titleStyle;

  const SwitchField({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isExtended = false,
    this.isRounded = true,
    this.borderRadius = BorderRadius.zero,
    this.image,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isExtended
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(14, 21, 14, 8),
      decoration: BoxDecoration(
        color: isExtended ? Colors.white : Colors.transparent,
        borderRadius: borderRadius != BorderRadius.zero
            ? borderRadius
            : BorderRadius.circular(10.0),
      ),
      child: ButtonField(
        title: title,
        titleStyle: titleStyle,
        trailingWidget: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xff3840F7),
        ),
        isRounded: isRounded,
        image: image,
        borderRadius: borderRadius,
      ),
    );
  }
}
