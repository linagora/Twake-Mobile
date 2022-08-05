import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';

import 'package:twake/pages/chat/chat_thumbnails_uploading.dart';
import 'package:twake/pages/chat/pinned_message_sheet.dart';
import 'package:twake/routing/app_router.dart';

import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/emojis.dart';
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
    return WillPopScope(
      onWillPop: () async {
        final uploadState = Get.find<FileUploadCubit>().state;
        if (uploadState.fileUploadStatus == FileUploadStatus.inProcessing) {
          Get.find<FileUploadCubit>()
              .clearFileUploadingState(needToCancelInProcessingFile: true);
          return false;
        }
        return true;
      },
      child: BlocBuilder<FileUploadCubit, FileUploadState>(
        bloc: Get.find<FileUploadCubit>(),
        builder: (context, state) {
          return Scaffold(
            appBar: state.fileUploadStatus != FileUploadStatus.inProcessing
                ? AppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    titleSpacing: 0.0,
                    shadowColor: Colors.transparent,
                    toolbarHeight: 60.0,
                    leadingWidth: 53.0,
                    leading: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        popBack();
                        Get.find<ThreadMessagesCubit>().reset();
                        Get.find<PinnedMessageCubit>().init();
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
                    title: BlocBuilder<ChannelsCubit, ChannelsState>(
                        bloc: Get.find<ChannelsCubit>(),
                        builder: (ctx, channelState) {
                          final selectedChannel =
                              (channelState as ChannelsLoadedSuccess)
                                      .selected ??
                                  channel;
                          return ChatHeader(
                              isDirect: selectedChannel.isDirect,
                              isPrivate: selectedChannel.isPrivate,
                              userId: selectedChannel.members.isNotEmpty
                                  ? selectedChannel.members.first
                                  : null,
                              name: selectedChannel.name,
                              icon:
                                  Emojis.getByName(selectedChannel.icon ?? ''),
                              avatars: selectedChannel.isDirect
                                  ? selectedChannel.avatars
                                  : const [],
                              membersCount: selectedChannel.stats?.members ?? 0,
                              onTap: () {
                                final cstate = Get.find<CompaniesCubit>().state
                                    as CompaniesLoadSuccess;
                                if (T == ChannelsCubit &&
                                    cstate.selected.canUpdateChannel) {
                                  NavigatorService.instance
                                      .navigateToChannelDetail();
                                }
                              });
                        }),
                  )
                : null,
            body: SafeArea(
              child: BlocBuilder<ChannelMessagesCubit, MessagesState>(
                bloc: Get.find<ChannelMessagesCubit>(),
                builder: (_, messagesState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PinnedMessageSheet(),
                    Flexible(
                        child:
                            _buildChatContent(messagesState, channel, context)),
                    ChatThumbnailsUploading(),
                    _composeBar(messagesState, draft, channel)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatContent(
      messagesState, Channel channel, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoading(messagesState),
        MessagesGroupedList(parentChannel: channel)
      ],
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

  Widget _composeBar(messagesState, String? draft, Channel channel) {
    return ComposeBar(
      autofocus: messagesState is MessageEditInProgress,
      initialText: (messagesState is MessageEditInProgress)
          ? messagesState.message.text
          : draft,
      onMessageSend: (content, context) async {
        final uploadState = Get.find<FileUploadCubit>().state;
        List<dynamic> attachments = const [];
        if (uploadState.listFileUploading.isNotEmpty) {
          attachments = uploadState.listFileUploading
              .where((fileUploading) => (fileUploading.file != null ||
                  fileUploading.messageFile != null))
              .map((e) => e.messageFile != null
                  ? e.messageFile!.toAttachment()
                  : e.file!.toAttachment())
              .toList();
        }
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
        // reset channels draft
        Get.find<T>().saveDraft(draft: null);
      },
      onTextUpdated: (text, ctx) {
        Get.find<T>().saveDraft(draft: text);
      },
    );
  }
}
