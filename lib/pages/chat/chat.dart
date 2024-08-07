import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
import 'package:twake/widgets/message/message_tile.dart';
import 'chat_header.dart';
import 'messages_grouped_list.dart';

class Chat<T extends BaseChannelsCubit> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final draft =
        (Get.find<T>().state as ChannelsLoadedSuccess).selected!.draft;
    final channel = (Get.find<T>().state as ChannelsLoadedSuccess).selected!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        shadowColor: Colors.grey[300],
        toolbarHeight: 60.0,
        leadingWidth: 53.0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            popBack();
            Get.find<BadgesCubit>().fetch();
            Get.find<ThreadMessagesCubit>().reset();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Color(0xff004dff),
            ),
          ),
        ),
        title: ChatHeader(
            isDirect: channel.isDirect,
            isPrivate: channel.isPrivate,
            userId: channel.members.first,
            // TODO: figure out why do we need this?
            name: channel.name,
            icon: channel.icon ?? '',
            membersCount: channel.membersCount,
            onTap: () {
              if (T == ChannelsCubit) {
                NavigatorService.instance.navigateToChannelDetail();
              }
            }),
      ),
      // ),
      body: BlocBuilder<ChannelMessagesCubit, MessagesState>(
        bloc: Get.find<ChannelMessagesCubit>(),
        builder: (_, messagesState) => Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                thickness: 1.0,
                height: 1.0,
                color: Color(0xffEEEEEE),
              ),
              if (messagesState is MessagesBeforeLoadInProgress)
                SizedBox(
                  height: Dim.hm4,
                  width: Dim.hm4,
                  child: Padding(
                    padding: EdgeInsets.all(Dim.widthMultiplier),
                    child: CircularProgressIndicator(),
                  ),
                ),
              MessagesGroupedList(parentChannel: channel),
              threadReply(context),
              ComposeBar(
                autofocus: messagesState is MessageEditInProgress,
                initialText: (messagesState is MessageEditInProgress)
                    ? messagesState.message.content.originalStr
                    : draft,
                onMessageSend: (content, context) async {
                  final stateThread = Get.find<ThreadMessagesCubit>().state;
                  final uploadState = Get.find<FileCubit>().state;
                  List<File> attachments = const [];
                  if (uploadState is FileUploadSuccess) {
                    attachments = uploadState.files;
                  }
                  if (stateThread is MessagesLoadSuccess) {
                    Get.find<ThreadMessagesCubit>().send(
                        originalStr: content,
                        attachments: attachments,
                        threadId: Globals.instance.threadId);
                    Get.find<ThreadMessagesCubit>().reset();
                  } else {
                    if (messagesState is MessageEditInProgress)
                      Get.find<ChannelMessagesCubit>().edit(
                          message: messagesState.message, editedText: content);
                    else {
                      final uploadState = Get.find<FileCubit>().state;
                      List<File> attachments = const [];
                      if (uploadState is FileUploadSuccess) {
                        attachments = uploadState.files;
                      }
                      Get.find<ChannelMessagesCubit>()
                          .send(originalStr: content, attachments: attachments);
                    }
                  }
                  // reset channels draft
                  Get.find<T>().saveDraft(draft: null);
                },
                onTextUpdated: (text, ctx) {
                  Get.find<T>().saveDraft(draft: text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget threadReply(BuildContext context) {
    return BlocBuilder<ThreadMessagesCubit, MessagesState>(
      bloc: Get.find<ThreadMessagesCubit>(),
      builder: (ctx, state) {
        if (state is MessagesLoadSuccess) {
          final _message = state.parentMessage;
          // TODO: add null check
          // if (_message == null) {
          //   _message =  ;
          // }
          return Column(
            children: [
              Divider(
                thickness: 1,
                height: 3,
                color: Color(0x1e000000),
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Reply to ",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black)),
                          Text(
                            '${_message!.sender}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          //TODO do we need to use user's color or not?
                          /* Text(
                                  '${_message.sender}',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: HSLColor.fromAHSL(
                                            1,
                                            _message.username.hashCode % 360,
                                            0.9,
                                            0.3)
                                        .toColor(),
                                  ),
                                ),*/
                        ],
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.15),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: TwacodeRenderer(
                                  _message.content.prepared,
                                  TextStyle(
                                      fontSize: 14.0,
                                      //fontWeight: FontWeight.w400,
                                      color: Color(0xFF818C99)),
                                  _message.username.hashCode % 360,
                                ).message,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Get.find<ThreadMessagesCubit>().reset();
                    },
                    iconSize: 25,
                    icon: Icon(CupertinoIcons.clear_thick_circled),
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ],
          );
        } else
          return Container();
      },
    );
  }
}
