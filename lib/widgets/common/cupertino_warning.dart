/* import 'package:flutter/cupertino.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/common/rich_text_span.dart';

class CupertinoWarning extends StatelessWidget {
  final String? icon;
  final List<RichTextSpan>? title;
  final String? confirmTitle;
  final Function? confirmAction;
  final String? cancelTitle;

  const CupertinoWarning({
    Key? key,
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
      message: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: CupertinoColors.black,
          ),
          children: <TextSpan>[
            ...title!.map((e) => e.buildSpan()),
          ],
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: confirmAction as void Function(),
          child: Text(
            confirmTitle!,
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
          cancelTitle!,
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
} */
