import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class ConfirmDialog extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final String cancelActionTitle;
  final String okActionTitle;
  final Function? cancelAction;
  final Function? okAction;

  const ConfirmDialog({
    Key? key,
    this.header,
    required this.body,
    required this.cancelActionTitle,
    required this.okActionTitle,
    this.cancelAction,
    this.okAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            header ?? SizedBox.shrink(),
            SizedBox(height: 22),
            body,
            SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                      alignment: Alignment.center,
                      child: ButtonTextBuilder(
                              Key('confirm_dialog_button_cancel'),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.5), onButtonClick: () {
                        cancelAction?.call();
                        Navigator.of(context).pop();
                      })
                          .setText(cancelActionTitle)
                          .setTextStyle(StylesConfig.commonTextStyle.copyWith(
                              color: const Color(0xffff3347), fontSize: 17.0))
                          .setHeight(44.0)
                          .setBackgroundColor(const Color(0xfff2f3f5))
                          .setBorderRadius(
                              BorderRadius.all(Radius.circular(10.0)))
                          .build()),
                ),
                SizedBox(width: 12.0),
                Flexible(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: ButtonTextBuilder(Key('confirm_dialog_button_ok'),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.5), onButtonClick: () {
                      okAction?.call();
                      Navigator.of(context).pop();
                    })
                        .setText(okActionTitle)
                        .setTextStyle(StylesConfig.commonTextStyle
                            .copyWith(color: Colors.white, fontSize: 17.0))
                        .setHeight(44.0)
                        .setBackgroundColor(const Color(0xff004dff))
                        .setBorderRadius(
                            BorderRadius.all(Radius.circular(10.0)))
                        .build(),
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
