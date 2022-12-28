import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';

class EmptyChatContainer extends StatelessWidget {
  final bool isDirect;
  final bool isError;
  final String userName;

  const EmptyChatContainer({
    Key? key,
    this.isDirect = false,
    this.isError = false,
    this.userName = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = isDirect
        ? AppLocalizations.of(context)!.noConversationInChat(userName)
        : AppLocalizations.of(context)!.noConversationInChannel;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    width: Dim.widthPercent(80),
                    padding:
                        const EdgeInsets.only(top: 16.0, left: 5, right: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0),
                      ),
                    ),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Image.asset(
                          imageTwake,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        top: 12.0, bottom: 16.0, left: 5, right: 5),
                    width: Dim.widthPercent(80),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18.0),
                        bottomRight: Radius.circular(18.0),
                      ),
                    ),
                    child: AutoSizeText(
                      isError
                          ? AppLocalizations.of(context)!.messageLoadError
                          : message,
                      minFontSize: 12.0,
                      maxFontSize: 15.0,
                      maxLines: 15,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessagesLoadingAnimation extends StatelessWidget {
  const MessagesLoadingAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        reverse: true,
        shrinkWrap: true,
        itemCount: 20,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final height = (Random().nextInt(50) + 80).toDouble();
          final width = (index.isOdd
                  ? (Random().nextInt(200) + 50)
                  : Dim.widthPercent(76))
              .toDouble();
          return Container(
            height: width < 200 ? 70 : height,
            constraints: BoxConstraints(
                maxWidth: Dim.widthPercent(90),
                maxHeight: Dim.heightPercent(50)),
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  emptyAvatar(context: context),
                  emptyMessage(
                      height: width < 200 ? 70 : height,
                      width: width.toDouble(),
                      context: context)
                ],
              ),
            ),
          );
        });
  }

  Widget emptyMessage(
      {required double height,
      required double width,
      required BuildContext context}) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: width,
      height: height,
      child: SkeletonAnimation(
        shimmerColor: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
        shimmerDuration: 1000,
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget emptyAvatar({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, right: 8, left: 8),
      child: Container(
        height: 36,
        width: 36,
        child: SkeletonAnimation(
          shimmerColor: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          shimmerDuration: 1000,
          child: Container(
            decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
