import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class TwakeAlertDialog extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final String okActionTitle;
  final Function? okAction;

  const TwakeAlertDialog({
    Key? key,
    this.header,
    required this.body,
    required this.okActionTitle,
    this.okAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: _buildCloseButton(context),
            ),
            header ?? SizedBox.shrink(),
            SizedBox(height: 8),
            body,
            SizedBox(height: 44),
            Container(
              alignment: Alignment.center,
              child: ButtonTextBuilder(Key('confirm_dialog_button_ok'),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withOpacity(0.5),
                  onButtonClick: () {
                    okAction?.call();
                    Navigator.of(context).pop();
                  },
              )
              .setText(okActionTitle)
              .setTextStyle(StylesConfig.commonTextStyle
                  .copyWith(color: Colors.white, fontSize: 17.0))
              .setHeight(44.0)
              .setBackgroundColor(const Color(0xff004dff))
              .setBorderRadius(
                  BorderRadius.all(Radius.circular(10.0)))
              .build(),
            ),
          ],
        ),
      ),
    );
  }

  _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Image.asset(
        imageClose,
        width: 24.0,
        height: 24.0,
      ),
    );
  }

}
