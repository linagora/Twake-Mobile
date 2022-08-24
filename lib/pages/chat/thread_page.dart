import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/pages/chat/inherited_message_animation.dart';
import 'package:twake/pages/chat/message_animation.dart';
import 'package:twake/pages/chat/pinned_message_sheet.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'messages_thread_list.dart';

class ThreadPage<T extends BaseChannelsCubit> extends StatefulWidget {
  final bool autofocus;

  const ThreadPage({this.autofocus: false});

  @override
  _ThreadPageState<T> createState() => _ThreadPageState<T>();

  static MessageAnimationCubit of(BuildContext context) {
    return context
        .findAncestorWidgetOfExactType<InheritedMessageAnimationCubit>()!
        .messageAnimationCubit;
  }
}

class _ThreadPageState<T extends BaseChannelsCubit>
    extends State<ThreadPage<T>> {
  bool autofocus = false;

  bool isDirect = false;

  GlobalKey _threadKey = GlobalKey();

  late MessageAnimationCubit messageAnimationCubit;

  @override
  void initState() {
    autofocus = widget.autofocus;
    messageAnimationCubit = MessageAnimationCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      child: BlocBuilder<ThreadMessagesCubit, MessagesState>(
          bloc: Get.find<ThreadMessagesCubit>(),
          builder: (ctx, messagesState) {
            if (messagesState is MessagesLoadSuccess &&
                messagesState.messages.isNotEmpty) {
              String name = messagesState.messages[0].firstName ??
                  '${messagesState.messages[0].username}';
              if (name.length > 20) {
                name = name.substring(0, 12) +
                    '...' +
                    name.substring(name.length - 3);
              }
              return Scaffold(
                body: InheritedMessageAnimationCubit(
                  messageAnimationCubit: messageAnimationCubit,
                  child: Stack(children: [
                    BlocBuilder<FileUploadCubit, FileUploadState>(
                        bloc: Get.find<FileUploadCubit>(),
                        builder: (context, state) {
                          return Scaffold(
                            appBar: state.fileUploadStatus !=
                                    FileUploadStatus.inProcessing
                                ? AppBar(
                                    titleSpacing: 0.0,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    elevation: 0,
                                    toolbarHeight: Dim.heightPercent(
                                        (kToolbarHeight * 0.15).round()),
                                    leading: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 20, 10, 20),
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .someonesMessages(name),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline1!
                                                        .copyWith(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800)),
                                                SizedBox(
                                                  width: 44,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Text(
                                                  channel.isDirect
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .threadReplies
                                                      : channel.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2!
                                                      .copyWith(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                            body: SafeArea(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    PinnedMessageSheet(),
                                    ThreadMessagesList<ThreadMessagesCubit>(
                                        key: _threadKey,
                                        parentChannel: channel),
                                    ComposeBar(
                                        autofocus: autofocus ||
                                            messagesState
                                                is MessageEditInProgress,
                                        initialText: (messagesState
                                                is MessageEditInProgress)
                                            ? messagesState.message.text
                                            : '',
                                        onMessageSend:
                                            (content, context) async {
                                          final uploadState =
                                              Get.find<FileUploadCubit>().state;
                                          List<dynamic> attachments = const [];
                                          if (uploadState
                                              .listFileUploading.isNotEmpty) {
                                            attachments = uploadState
                                                .listFileUploading
                                                .where((fileUploading) =>
                                                    fileUploading.file != null)
                                                .map((e) =>
                                                    e.file!.toAttachment())
                                                .toList();
                                          }
                                          if (messagesState
                                              is MessageEditInProgress) {
                                            Get.find<ThreadMessagesCubit>()
                                                .edit(
                                                    message:
                                                        messagesState.message,
                                                    editedText: content,
                                                    newAttachments:
                                                        attachments);
                                          } else {
                                            isDirect = channel.isDirect;
                                            Get.find<ThreadMessagesCubit>()
                                                .send(
                                              originalStr: content,
                                              attachments: attachments,
                                              threadId:
                                                  Globals.instance.threadId,
                                              isDirect: channel.isDirect,
                                            );
                                          }
                                          // reset thread draft
                                          Get.find<ThreadMessagesCubit>()
                                              .saveDraft(draft: null);
                                        },
                                        onTextUpdated: (text, ctx) {
                                          Get.find<ThreadMessagesCubit>()
                                              .saveDraft(draft: text);
                                        }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    LongPressMessageAnimation<ThreadMessagesCubit>(
                        messagesListKey: _threadKey, isDirect: isDirect),
                  ]),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  titleSpacing: 0.0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  toolbarHeight:
                      Dim.heightPercent((kToolbarHeight * 0.15).round()),
                  leading: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PinnedMessageSheet(),
                        Spacer(),
                        ComposeBar(
                          onMessageSend: (_, conext) => {},
                          onTextUpdated: (_, conext) => {},
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }
}
