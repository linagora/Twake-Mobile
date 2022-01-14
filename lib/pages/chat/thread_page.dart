import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'messages_thread_list.dart';

class ThreadPage<T extends BaseChannelsCubit> extends StatefulWidget {
  final bool autofocus;

  const ThreadPage({this.autofocus: false});

  @override
  _ThreadPageState<T> createState() => _ThreadPageState<T>();
}

class _ThreadPageState<T extends BaseChannelsCubit>
    extends State<ThreadPage<T>> {
  bool autofocus = false;

  @override
  void initState() {
    autofocus = widget.autofocus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final channel = (Get.find<T>().state as ChannelsLoadedSuccess).selected!;

    Get.create<FileCubit>(() => FileCubit(), permanent: false);
    Get.create<FileUploadCubit>(() => FileUploadCubit(), permanent: false);

    return BlocBuilder<ThreadMessagesCubit, MessagesState>(
        bloc: Get.find<ThreadMessagesCubit>(),
        buildWhen: (_, state) {
          return state is MessagesLoadSuccess;
        },
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
              appBar: AppBar(
                titleSpacing: 0.0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shadowColor: Get.isDarkMode
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                                AppLocalizations.of(context)!
                                    .someonesMessages(name),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .copyWith(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800)),
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
                                  ? AppLocalizations.of(context)!.threadReplies
                                  : channel.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
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
              ),
              body: SafeArea(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: Dim.heightPercent(88),
                    minHeight: Dim.heightPercent(78),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ThreadMessagesList<ThreadMessagesCubit>(
                        parentChannel: channel,
                      ),
                      ComposeBar(
                          autofocus: autofocus ||
                              messagesState is MessageEditInProgress,
                          initialText: (messagesState is MessageEditInProgress)
                              ? messagesState.message.text
                              : '',
                          onMessageSend: (content, context) async {
                            final uploadState =
                                Get.find<FileUploadCubit>().state;
                            List<dynamic> attachments = const [];
                            if (uploadState.listFileUploading.isNotEmpty) {
                              attachments = uploadState.listFileUploading
                                  .where((fileUploading) =>
                                      fileUploading.file != null)
                                  .map((e) => e.file!.toAttachment())
                                  .toList();
                            }
                            if (messagesState is MessageEditInProgress) {
                              Get.find<ThreadMessagesCubit>().edit(
                                  message: messagesState.message,
                                  editedText: content,
                                  newAttachments: attachments);
                            } else {
                              Get.find<ThreadMessagesCubit>().send(
                                originalStr: content,
                                attachments: attachments,
                                threadId: Globals.instance.threadId,
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
          } else {
            return Container();
          }
        });
  }
}
