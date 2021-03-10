import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';

class CupertinoWarning extends StatelessWidget {
  final String icon;
  final String title;
  final String confirmTitle;
  final Function confirmAction;
  final String cancelTitle;

  const CupertinoWarning({
    Key key,
    this.icon,
    this.title,
    this.confirmTitle,
    this.confirmAction,
    this.cancelTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: SelectableAvatar(icon: icon, size: 56.0),
      message: Text(
        title,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: Color(0xff6d7885),
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: confirmAction,
          child: Text(
            confirmTitle,
            maxLines: 1,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
              color: Color(0xfff04820),
            ),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          cancelTitle,
          maxLines: 1,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 19.0,
            fontWeight: FontWeight.w600,
            color: Color(0xff007aff),
          ),
        ),
      ),
    );
  }
}
