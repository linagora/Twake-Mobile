import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_state.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/pages/chat/pinned_message_sheet.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/animated_menu_message.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
import 'chat_header.dart';

class Chat<T extends BaseChannelsCubit> extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatState<T>();
}

class _ChatState<T extends BaseChannelsCubit> extends State<Chat> {
  GlobalKey _messagesListKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool isDirect = false;
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
      child: Scaffold(
        body: Stack(
          children: [
            BlocBuilder<FileUploadCubit, FileUploadState>(
              bloc: Get.find<FileUploadCubit>(),
              builder: (context, state) {
                return Scaffold(
                  appBar: state.fileUploadStatus !=
                          FileUploadStatus.inProcessing
                      ? AppBar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                isDirect = selectedChannel.isDirect;
                                return ChatHeader(
                                    isDirect: selectedChannel.isDirect,
                                    isPrivate: selectedChannel.isPrivate,
                                    userId: selectedChannel.members.isNotEmpty
                                        ? selectedChannel.members.first
                                        : null,
                                    name: selectedChannel.name,
                                    icon: Emojis.getByName(
                                        selectedChannel.icon ?? ''),
                                    avatars: selectedChannel.isDirect
                                        ? selectedChannel.avatars
                                        : const [],
                                    membersCount:
                                        selectedChannel.stats?.members ?? 0,
                                    onTap: () {
                                      final cstate = Get.find<CompaniesCubit>()
                                          .state as CompaniesLoadSuccess;
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
                              child: _buildChatContent(messagesState, channel,
                                  context, _messagesListKey)),
                          _composeBar(messagesState, draft, channel)
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<MessageAnimationCubit, MessageAnimationState>(
              bloc: Get.find<MessageAnimationCubit>(),
              builder: ((context, state) {
                if (state is! MessageAnimationStart) {
                  return Container();
                }

                // find size of messages list
                Size? size;
                Offset? messageListTopLeftPoint;
                if (_messagesListKey.currentContext != null &&
                    _messagesListKey.currentContext?.findRenderObject() !=
                        null) {
                  size = (_messagesListKey.currentContext?.findRenderObject()
                          as RenderBox)
                      .size;
                  messageListTopLeftPoint = (_messagesListKey.currentContext
                          ?.findRenderObject() as RenderBox)
                      .localToGlobal(Offset.zero);
                }

                return MenuMessageDropDown<ChannelMessagesCubit>(
                  message: state.longPressMessage,
                  itemPositionsListener: state.itemPositionListener,
                  clickedItem: state.longPressIndex,
                  messagesListSize: size,
                  messageListPosition: messageListTopLeftPoint,
                  onReply: () {
                    Get.find<MessageAnimationCubit>().endAnimation();

                    NavigatorService.instance.navigate(
                      channelId: state.longPressMessage.channelId,
                      threadId: state.longPressMessage.id,
                      reloadThreads: false,
                    );
                  },
                  onEdit: () {
                    Get.find<MessageAnimationCubit>().endAnimation();

                    Get.find<ChannelMessagesCubit>()
                        .startEdit(message: state.longPressMessage);
                  },
                  onCopy: () {
                    Get.find<MessageAnimationCubit>().endAnimation();

                    FlutterClipboard.copy(state.longPressMessage.text);

                    Utilities.showSimpleSnackBar(
                        message:
                            AppLocalizations.of(context)!.messageCopiedInfo,
                        context: context,
                        iconData: Icons.copy);
                  },
                  onDelete: () {
                    Get.find<MessageAnimationCubit>().endAnimation();
                    Get.find<ChannelMessagesCubit>()
                        .delete(message: state.longPressMessage);
                  },
                  onPinMessage: () {
                    Get.find<MessageAnimationCubit>().endAnimation();

                    Get.find<PinnedMessageCubit>().pinMessage(
                        message: state.longPressMessage, isDirect: isDirect);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(
      messagesState, Channel channel, BuildContext context, Key? key) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoading(messagesState),
        MessagesGroupedList(parentChannel: channel, key: key)
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
