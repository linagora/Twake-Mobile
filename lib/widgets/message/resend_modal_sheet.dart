import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/message/message.dart';

class ResendModalSheet extends StatelessWidget {
  final Message message;
  final bool isThread;
  const ResendModalSheet(
      {required this.message, required this.isThread, Key? key})
      : super(key: key);

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
            color: Colors.white,
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
                    'Your message was not sent. Tap Try Again to resend this message',
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
                          "Try again",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF004DFF),
                          ),
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
                          "Delete this message",
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
                              .delete(message: message)
                          : Get.find<ChannelMessagesCubit>()
                              .delete(message: message);

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
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Container(
                child: Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
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
