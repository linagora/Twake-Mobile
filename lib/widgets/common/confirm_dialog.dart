import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/config/image_path.dart';
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
                          .setTextStyle(
                            Theme.of(context).textTheme.headline5!.copyWith(
                                fontSize: 17.0, fontWeight: FontWeight.w500),
                          )
                          .setHeight(44.0)
                          .setBackgroundColor(Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3))
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
                        .setTextStyle(Get.isDarkMode
                            ? Theme.of(context).textTheme.headline1!.copyWith(
                                fontSize: 17.0, fontWeight: FontWeight.normal)
                            : Theme.of(context).textTheme.bodyText1!.copyWith(
                                fontSize: 17.0, fontWeight: FontWeight.normal))
                        .setHeight(44.0)
                        .setBackgroundColor(
                            Theme.of(context).colorScheme.surface)
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
