import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
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
            Navigator.of(context).pop();
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
            userId:
                channel.members.first, // TODO: figure out why do we need this?
            name: channel.name,
            icon: channel.icon,
            membersCount: channel.membersCount,
            onTap: () {} // TODO: navigate to channel edit page
            ),
      ),
      // ),
      body: BlocBuilder<ChannelMessagesCubit, MessagesState>(
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
              MessagesGroupedList(),
              ComposeBar(
                  autofocus: messagesState is MessageEditInProgress,
                  initialText: (messagesState is MessageEditInProgress)
                      ? messagesState.message.content.originalStr
                      : draft,
                  onMessageSend: (content, context) async {
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
                    // reset channels draft
                    Get.find<T>().saveDraft(draft: null);
                  },
                  onTextUpdated: (text, ctx) {
                    Get.find<T>().saveDraft(draft: text);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
