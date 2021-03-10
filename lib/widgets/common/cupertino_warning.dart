import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';

class CupertinoWarning extends StatelessWidget {
  final String icon;
  final String title;
  final String confirmTitle;
  final Function confirmAction;
  final String cancelTitle;
  final Function cancelAction;

  const CupertinoWarning({
    Key key,
    this.icon,
    this.title,
    this.confirmTitle,
    this.confirmAction,
    this.cancelTitle,
    this.cancelAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: SelectableAvatar(icon: icon, size: 56.0),
      message: AutoSizeText(
        title,
        minFontSize: 12,
        maxFontSize: 16,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Color(0xff6d7885),
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: confirmAction,
          child: AutoSizeText(
            confirmTitle,
            minFontSize: 12,
            maxFontSize: 16,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Color(0xfff04820),
            ),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: cancelAction,
        child: AutoSizeText(
          cancelTitle,
          minFontSize: 12,
          maxFontSize: 16,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Color(0xff007aff),
          ),
        ),
      ),
    );
  }
}
