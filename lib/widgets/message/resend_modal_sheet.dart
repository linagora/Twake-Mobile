import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/message/message.dart';

class ResendModalSheet extends StatelessWidget {
  final Message message;
  final bool isThread;
  const ResendModalSheet({
    required this.message,
    required this.isThread,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(22.0),
          ),
          child: Container(
            height: 160,
            width: Dim.widthPercent(94),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.messageNotSentInfo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6D7885),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      width: Dim.widthPercent(80),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          AppLocalizations.of(context)!.tryAgain,
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    onTap: () {
                      isThread
                          ? Get.find<ThreadMessagesCubit>()
                              .resend(message: message)
                          : Get.find<ChannelMessagesCubit>()
                              .resend(message: message);
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      width: Dim.widthPercent(80),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          AppLocalizations.of(context)!.deleteMessageInfo,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      isThread
                          ? Get.find<ThreadMessagesCubit>()
                              .delete(message: message, local: true)
                          : Get.find<ChannelMessagesCubit>()
                              .delete(message: message, local: true);

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 25),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Container(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                height: 60,
                width: Dim.widthPercent(94),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
