import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class WarningDialog extends StatelessWidget {
  final String? title;
  final String? leadingActionTitle;
  final Function? leadingAction;
  final String? trailingActionTitle;
  final Function? trailingAction;

  const WarningDialog({
    Key? key,
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
      backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
      child: Container(
        width: 296.0,
        height: 142.0,
        padding: const EdgeInsets.fromLTRB(24.0, 14.0, 24.0, 14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  title!,
                  minFontSize: 12,
                  maxFontSize: 16,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 92.0,
                  height: 36.0,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      leadingActionTitle!,
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  width: 92.0,
                  height: 36.0,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: trailingAction as void Function()?,
                    child: Text(
                      trailingActionTitle!,
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
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
