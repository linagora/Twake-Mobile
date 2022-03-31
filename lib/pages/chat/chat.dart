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
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/pages/chat/chat_attachment.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
import 'chat_header.dart';
import 'messages_grouped_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
                    shadowColor: Get.isDarkMode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
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
                    _pinnedMessagesSheet(context, channel),
                    Flexible(child: _buildChatContent(messagesState, channel)),
                    _threadReply(context),
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

  _unpinMessage(Message message, context) async {
    final bool result =
        await Get.find<PinnedMessageCubit>().unpinMessage(message: message);
    if (!result)
      Utilities.showSimpleSnackBar(
          context: context, message: AppLocalizations.of(context)!
                                    .somethingWentWrong);
  }

  Widget _pinnedMessagesSheet(BuildContext context, Channel channel) {
    final ItemScrollController itemScrollController = ItemScrollController();
    final ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();
    return BlocBuilder<PinnedMessageCubit, PinnedMessageState>(
        bloc: Get.find<PinnedMessageCubit>(),
        builder: (ctx, state) {
          if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: Get.isDarkMode ? 0 : 0.5,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.3),
                  ),
                ),
              ),
              alignment: Alignment.centerLeft,
              height: 56,
              width: Dim.widthPercent(99),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: 10,
                      child: ScrollablePositionedList.builder(
                        shrinkWrap: true,
                        addAutomaticKeepAlives: true,
                        key: PageStorageKey("uniq"),
                        itemCount: state.pinnedMessageList.length,
                        itemBuilder: (context, index) => _scrollBarTile(
                            index,
                            state.selected,
                            state.pinnedMessageList.length,
                            context),
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                      )),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Text(
                                AppLocalizations.of(context)!.pinnedMessages,
                                style: Get.theme.textTheme.headline4!.copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w300),
                              ),
                            ),
                            _pinnedMessagesTile(
                                state.pinnedMessageList[state.selected]),
                          ]),
                      onTap: () async {
                        final bool result = await Get.find<PinnedMessageCubit>()
                            .selectPinnedMessage();
                        final selected =
                            state.pinnedMessageList.length - 1 == state.selected
                                ? 0
                                : state.selected + 1;
                        if (result)
                          itemScrollController.scrollTo(
                              index: selected,
                              duration: Duration(milliseconds: 700),
                              curve: Curves.linear);
                      }),
                  Spacer(),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 2),
                      child: state.pinnedMessageList.length == 1
                          ? Icon(
                              Icons.clear,
                              color: Theme.of(context).colorScheme.surface,
                            )
                          : Image.asset(
                              imageListPinned,
                              color: Theme.of(context).colorScheme.surface,
                              height: 30,
                              width: 30,
                            ),
                    ),
                    onTap: () => state.pinnedMessageList.length == 1
                        ? _unpinMessage(
                            state.pinnedMessageList[state.selected], context)
                        : push(RoutePaths.channelPinnedMessages.path,
                            arguments: channel),
                  )
                ],
              ),
            );
          }
          return SizedBox.shrink();
        });
  }

  Widget _threadReply(BuildContext context) {
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
                  color: Theme.of(context).colorScheme.secondaryContainer),
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

  Widget _pinnedMessagesTile(Message message) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        width: Dim.widthPercent(85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Container(
                constraints: BoxConstraints(maxWidth: Dim.widthPercent(85)),
                child: Text(
                  '${message.text}',
                  style: Get.theme.textTheme.headline1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scrollBarTile(
      int index, int selected, int length, BuildContext context) {
    if (length == 1) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14.0),
          ),
          height: 50,
          width: 2,
        ),
      );
    } else if (length == 2) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: index == selected
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 25,
                width: 2,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 25,
                width: 2,
              ),
      );
    } else if (length == 3) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: index == selected
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 15,
                width: 2,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 15,
                width: 2,
              ),
      );
    } else
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: index == selected
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 14,
                width: 2,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 14,
                width: 2,
              ),
      );
  }
}
