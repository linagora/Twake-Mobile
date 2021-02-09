import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SheetTitleBar extends StatelessWidget {
  const SheetTitleBar({
    Key key,
    @required this.title,
    this.leadingTitle,
    this.trailingTitle,
    this.leadingAction,
    this.trailingAction,
  }) : super(key: key);

  final String title;
  final String leadingTitle;
  final String trailingTitle;
  final Function leadingAction;
  final Function trailingAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff7f7f7),
      height: 52,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: leadingAction != null
            ? ((leadingTitle != 'Back') ? 12.0 : 0.0)
            : 12.0,
        right: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: leadingAction,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (leadingAction != null &&
                    leadingTitle != 'Close' &&
                    leadingTitle != 'Cancel')
                  Icon(
                    CupertinoIcons.back,
                    color: Color(0xff3840F7),
                  ),
                Text(
                  leadingTitle ?? '',
                  style: TextStyle(
                    color: leadingAction != null
                        ? Color(0xff3840F7)
                        : Color(0xffa2a2a2),
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign:
                      leadingTitle != 'Back' ? TextAlign.start : TextAlign.end,
                ),
              ],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: trailingAction,
            child: Text(
              trailingTitle ?? '',
              style: TextStyle(
                color: trailingAction != null
                    ? Color(0xff3840F7)
                    : Color(0xffa2a2a2),
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
