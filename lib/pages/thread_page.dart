import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/message/compose_bar.dart';
import 'package:twake/widgets/thread/thread_messages_list.dart';

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

    return BlocBuilder<ThreadMessagesCubit, MessagesState>(
        bloc: Get.find<ThreadMessagesCubit>(),
        builder: (ctx, messagesState) {
          return messagesState is MessagesLoadSuccess
              ? Scaffold(
                  appBar: AppBar(
                      titleSpacing: 0.0,
                      shadowColor: Colors.grey[300],
                      toolbarHeight:
                          Dim.heightPercent((kToolbarHeight * 0.15).round()),
                      leading: BackButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      title: Row(
                        children: [
                          channel.isDirect
                              ? StackedUserAvatars(
                                  userIds: channel.members,
                                )
                              : TextAvatar(
                                  channel.icon,
                                  fontSize: Dim.tm4(),
                                ),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Threaded replies',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff444444),
                                ),
                              ),
                              SizedBox(height: 1.0),
                              Text(
                                channel.name,
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff92929C),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      )),
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
                          ThreadMessagesList(),
                          ComposeBar(
                              autofocus: autofocus ||
                                  messagesState is MessageEditInProgress,
                              initialText: (messagesState
                                      is MessageEditInProgress)
                                  ? messagesState.message.content.originalStr
                                  : '',
                              onMessageSend: (content, context) async {
                                if (messagesState is MessageEditInProgress)
                                  Get.find<ThreadMessagesCubit>().edit(
                                      message: messagesState.message,
                                      editedText: content);
                                else {
                                  final uploadState =
                                      Get.find<FileCubit>().state;
                                  List<File> attachments = const [];
                                  if (uploadState is FileUploadSuccess) {
                                    attachments = uploadState.files;
                                  }
                                  Get.find<ThreadMessagesCubit>().send(
                                      originalStr: content,
                                      attachments: attachments,
                                      threadId: Globals.instance.threadId);
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
                )
              : Center(child: CircularProgressIndicator());
        });
  }
}
