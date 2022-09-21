import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/quote_message_cubit/quote_message_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/utils/twacode.dart';

class QuoteMessage extends StatelessWidget {
  const QuoteMessage(
      {required this.message,
      this.paddingLeft: 0,
      this.paddingRight: 0,
      this.paddingBottom: 0,
      this.paddingTop: 0,
      this.showCloseButton: false,
      this.isExpanded: false,
      Key? key})
      : super(key: key);
  final Message message;
  final bool showCloseButton;
  final bool isExpanded;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    return isExpanded
        ? Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: paddingTop,
                  bottom: paddingBottom),
              child: Stack(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildLine(context),
                      _buildQuote(context),
                    ],
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: _buildCloseButton(context))
                ],
              ),
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.find<QuoteMessageCubit>().jumpToMessage(message),
            child: Padding(
              padding: EdgeInsets.only(
                  left: paddingLeft,
                  right: paddingRight,
                  top: paddingTop,
                  bottom: paddingBottom),
              child: IgnorePointer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildLine(context),
                    _buildQuote(context),
                    _buildCloseButton(context)
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildQuote(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 2,
        ),
        _buildSender(context),
        _buildQuoteMessage(context),
        const SizedBox(
          height: 2,
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? Theme.of(context).iconTheme.color
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),
        width: 2.5,
        height: message.files!.isNotEmpty
            ? message.text != ''
                ? 120
                : 95
            : 36,
      ),
    );
  }

  Widget _buildQuoteMessage(BuildContext context) {
    return message.subtype == MessageSubtype.deleted
        ? Text(
            AppLocalizations.of(context)!.messageDeleted,
            style: Theme.of(context).textTheme.headline1!,
          )
        : Container(
            constraints: BoxConstraints(
              // To fit the size of the text field
              maxWidth: (Dim.widthPercent(99) - 105),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.files!.isNotEmpty)
                  TwacodeRenderer(
                    twacode: [''],
                    isLimitedSize: true,
                    fileIds: message.files,
                    parentStyle: Theme.of(context).textTheme.headline1!,
                    userUniqueColor: message.username.hashCode % 360,
                    messageLinks: message.messageLinks,
                  ).message,
                if (message.text != '')
                  TwacodeRenderer(
                    twacode: message.blocks.length == 0
                        ? [message.text]
                        : message.blocks,
                    isLimitedSize: true,
                    fileIds: [],
                    parentStyle: Theme.of(context).textTheme.headline1!,
                    userUniqueColor: message.username.hashCode % 360,
                    messageLinks: message.messageLinks,
                  ).message,
              ],
            ),
          );
  }

  Widget _buildSender(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        message.sender,
        style: Get.isDarkMode? Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontSize: 13, fontWeight: FontWeight.w400):Theme.of(context)
            .textTheme
            .headline4!
            .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return showCloseButton
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () => Get.find<QuoteMessageCubit>().init(),
                  child: Icon(
                    CupertinoIcons.clear,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }
}
