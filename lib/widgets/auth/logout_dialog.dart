import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  final String title;
  final String leadingActionTitle;
  final Function leadingAction;
  final String trailingActionTitle;
  final Function trailingAction;

  const LogoutDialog({
    Key key,
    this.title,
    this.leadingActionTitle,
    this.leadingAction,
    this.trailingActionTitle,
    this.trailingAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        width: 296.0,
        height: 142.0,
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff6d7885),
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 92.0,
                  height: 36.0,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      leadingActionTitle,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff837eff),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 92.0,
                  height: 36.0,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: trailingAction,
                    child: Text(
                      trailingActionTitle,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffff3b30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
