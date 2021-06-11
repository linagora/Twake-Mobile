import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/pages/chat/chat_header.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
import 'chat_header.dart';
import 'messages_grouped_list.dart';

class Chat<T extends BaseChannelsCubit> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final draft =
        (Get.find<T>().state as ChannelsLoadedSuccess).selected!.draft;

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
        //   title: BlocBuilder<MessagesBloc, MessagesState>(
        //      BlocBuilder<EditChannelCubit, EditChannelState>(
        //         builder: (context, editState) {
        //           var canEdit = false;
        //           var memberId = '';
        //           String? icon = '';
        //           var isPrivate = false;
        //           int? membersCount = 0;
        //
        //           if (parentChannel is Channel) {
        //             isPrivate = parentChannel.visibility == 'private';
        //             icon = parentChannel.icon;
        //             membersCount = parentChannel.membersCount;
        //
        //             // Possible permissions:
        //             // ['UPDATE_NAME', 'UPDATE_DESCRIPTION',
        //             // 'ADD_MEMBER', 'REMOVE_MEMBER',
        //             // 'UPDATE_PRIVACY','DELETE_CHANNEL']
        //             final permissions = parentChannel.permissions!;
        //
        //             if (permissions.contains('UPDATE_NAME') ||
        //                 permissions.contains('UPDATE_DESCRIPTION') ||
        //                 permissions.contains('ADD_MEMBER') ||
        //                 permissions.contains('REMOVE_MEMBER') ||
        //                 permissions.contains('UPDATE_PRIVACY') ||
        //                 permissions.contains('DELETE_CHANNEL')) {
        //               canEdit = true;
        //             } else {
        //               canEdit = false;
        //             }
        //           } else if (parentChannel is Direct &&
        //               parentChannel.members != null) {
        //             final userId = ProfileBloc.userId;
        //             memberId =
        //                 parentChannel.members!.firstWhere((id) => id != userId);
        //           }
        //
        //           if (editState is EditChannelSaved) {
        //             context
        //                 .read<MemberCubit>()
        //                 .fetchMembers(channelId: channelId);
        //           }
        //
        //           return ChatHeader(
        //             isDirect: parentChannel,
        //             isPrivate: isPrivate,
        //             userId: memberId,
        //             name: parentChannel!.name,
        //             icon: icon,
        //             membersCount: membersCount,
        //             onTap: canEdit ? () => _goEdit(context, state) : null,
        //           );
        //         },
        //       );
        //     },
        //   ),
        // ),
      ),
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

  void _goEdit(BuildContext context, MessagesState state) async {
    final params =
        await openEditChannel(context, state.parentChannel as Channel);
    if (params != null && params.length > 0) {
      final editingState = params.first;
      if (editingState is EditChannelDeleted) {
        Navigator.of(context).maybePop();
      }
    }
  }
}
