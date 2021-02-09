import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/sheets/button_field.dart';

class SwitchField extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final bool isExtended;

  const SwitchField({
    Key key,
    @required this.title,
    @required this.value,
    @required this.onChanged,
    this.isExtended = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isExtended ? Colors.white : Colors.transparent,
      padding: isExtended
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(14, 21, 14, 8),
      child: ButtonField(
        title: title,
        trailingWidget: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xff3840F7),
        ),
        isExtended: isExtended,
      ),
    );
  }
}
