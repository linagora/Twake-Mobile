import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/pages/chat/chat_attachment.dart';
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
    return BlocBuilder<FileUploadCubit, FileUploadState>(
      bloc: Get.find<FileUploadCubit>(),
      builder: (context, state) {
        return Scaffold(
          appBar: state.fileUploadStatus != FileUploadStatus.inProcessing
              ? AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  titleSpacing: 0.0,
                  shadowColor: Get.isDarkMode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  toolbarHeight: 60.0,
                  leadingWidth: 53.0,
                  leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      popBack();
                      Get.find<ThreadMessagesCubit>().reset();
                      // TODO: Currently, no need to clean cached files.
                      // Once there are some related performance bugs occur in the future,
                      // just un-comment this and test
                      // Get.find<CacheFileCubit>().cleanCachedFiles();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                  title: ChatHeader(
                      isDirect: channel.isDirect,
                      isPrivate: channel.isPrivate,
                      userId: channel.members.isNotEmpty
                          ? channel.members.first
                          : null,
                      name: channel.name,
                      icon: Emojis.getByName(channel.icon ?? ''),
                      avatars: channel.isDirect ? channel.avatars : const [],
                      membersCount: channel.membersCount,
                      onTap: () {
                        final cstate = Get.find<CompaniesCubit>().state
                            as CompaniesLoadSuccess;
                        if (T == ChannelsCubit &&
                            cstate.selected.canUpdateChannel) {
                          NavigatorService.instance.navigateToChannelDetail();
                        }
                      }),
                )
              : null,
          body: SafeArea(
            child: BlocBuilder<ChannelMessagesCubit, MessagesState>(
              bloc: Get.find<ChannelMessagesCubit>(),
              builder: (_, messagesState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: _buildChatContent(messagesState, channel)),
                  threadReply(context),
                  _composeBar(messagesState, draft, channel)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatContent(messagesState, Channel channel) {
    return BlocBuilder<FileUploadCubit, FileUploadState>(
      bloc: Get.find<FileUploadCubit>(),
      builder: (context, state) {
        if (state.fileUploadStatus == FileUploadStatus.inProcessing) {
          return ChatAttachment(senderName: channel.name);
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                  thickness: 1.0,
                  height: 1.0,
                  color: Get.isDarkMode
                      ? Theme.of(context).colorScheme.primary
                      : Color(0xFFEEEEEE)),
              _buildLoading(messagesState),
              MessagesGroupedList(parentChannel: channel)
            ],
          );
        }
      },
    );
  }

  Widget _buildLoading(messagesState) {
    if (messagesState is MessagesBeforeLoadInProgress)
      SizedBox(
        height: Dim.hm4,
        width: Dim.hm4,
        child: Padding(
          padding: EdgeInsets.all(Dim.widthMultiplier),
          child: CircularProgressIndicator(),
        ),
      );
    return SizedBox.shrink();
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
                  color: Theme.of(context).colorScheme.secondaryVariant),
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
                          Text(AppLocalizations.of(context)!.replyTo,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal)),
                          Container(
                            constraints:
                                BoxConstraints(maxWidth: Dim.widthPercent(70)),
                            child: Text('${_message.sender}',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: Dim.widthPercent(80),
                            child: TwacodeRenderer(
                              twacode: _message.blocks.length == 0
                                  ? [_message.text]
                                  : _message.blocks,
                              fileIds: _message.files,
                              parentStyle: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
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

  Widget _composeBar(messagesState, String? draft, Channel channel) {
    return ComposeBar(
      autofocus: messagesState is MessageEditInProgress,
      initialText: (messagesState is MessageEditInProgress)
          ? messagesState.message.text
          : draft,
      onMessageSend: (content, context) async {
        final stateThread = Get.find<ThreadMessagesCubit>().state;
        final uploadState = Get.find<FileUploadCubit>().state;
        List<dynamic> attachments = const [];
        if (uploadState.listFileUploading.isNotEmpty) {
          attachments = uploadState.listFileUploading
              .where((fileUploading) => fileUploading.file != null)
              .map((e) => e.file!.toAttachment())
              .toList();
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
          if (messagesState is MessageEditInProgress) {
            Get.find<ChannelMessagesCubit>().edit(
                message: messagesState.message,
                editedText: content,
                newAttachments: attachments);
          } else {
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
    );
  }
}
