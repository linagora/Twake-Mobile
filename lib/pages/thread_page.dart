import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/utils/emojis.dart';
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!channel.isDirect)
                          Container(
                            alignment: Alignment.topLeft,
                            child: TextAvatar(
                              Emojis.getByName(channel.icon ?? ''),
                              fontSize: Dim.tm4(),
                            ),
                          ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "${messagesState.messages[0].firstName}'s messages",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff444444),
                                ),
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              channel.isDirect
                                  ? 'Threaded replies'
                                  : channel.name,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff92929C),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 55,
                        ),
                        if (!channel.isDirect)
                          SizedBox(
                            width: 35,
                          ),
                        Spacer()
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
                          ThreadMessagesList(parentChannel: channel),
                          ComposeBar(
                              autofocus: autofocus ||
                                  messagesState is MessageEditInProgress,
                              initialText:
                                  (messagesState is MessageEditInProgress)
                                      ? messagesState.message.text
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
