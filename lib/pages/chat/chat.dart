import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/cache_file_cubit/cache_file_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/utils/twacode.dart';
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
            popBack();
            Get.find<ThreadMessagesCubit>().reset();
            Get.find<CacheFileCubit>().cleanCachedFiles();
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
            userId: channel.members.isNotEmpty ? channel.members.first : null,
            name: channel.name,
            icon: Emojis.getByName(channel.icon ?? ''),
            avatars: channel.isDirect ? channel.avatars : const [],
            membersCount: channel.membersCount,
            onTap: () {
              final cstate =
                  Get.find<CompaniesCubit>().state as CompaniesLoadSuccess;
              if (T == ChannelsCubit && cstate.selected.canUpdateChannel) {
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
                    ? messagesState.message.text
                    : draft,
                onMessageSend: (content, context) async {
                  final stateThread = Get.find<ThreadMessagesCubit>().state;
                  final uploadState = Get.find<FileCubit>().state;
                  List<File> attachments = const [];
                  if (uploadState is FileUploadSuccess) {
                    attachments = uploadState.files;
                  }
                  if (stateThread is MessagesLoadSuccessSwipeToReply) {
                    await Get.find<ThreadMessagesCubit>().send(
                      originalStr: content,
                      attachments: attachments,
                      threadId: stateThread.messages.first.id,
                      isDirect: channel.isDirect,
                    );
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
                      Get.find<ChannelMessagesCubit>().send(
                        originalStr: content,
                        attachments: attachments,
                        isDirect: channel.isDirect,
                      );
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
        if (state is MessagesLoadSuccessSwipeToReply) {
          final _message = state.messages.first;
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
                          Text(
                            AppLocalizations.of(context)!.replyTo,
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          Container(
                            constraints:
                                BoxConstraints(maxWidth: Dim.widthPercent(70)),
                            child: Text(
                              '${_message.sender}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: Dim.widthPercent(80),
                            child: TwacodeRenderer(
                              key: ValueKey('twacode-${_message.hash}'),
                              twacode: _message.blocks,
                              files: _message.files,
                              parentStyle: TextStyle(
                                fontSize: 14.0,
                                //fontWeight: FontWeight.w400,
                                color: Color(0xFF818C99),
                              ),
                              userUniqueColor: _message.username.hashCode % 360,
                              isSwipe: true,
                            ).messageOnSwipe,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                        ],
                      ),
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
