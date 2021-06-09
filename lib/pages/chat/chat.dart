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
import 'package:twake/utils/navigation.dart';
import 'package:twake/utils/twacode.dart';

class Chat<T extends BaseChannelsCubit> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? draft = '';
    String? channelId;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        shadowColor: Colors.grey[300],
        toolbarHeight: 60.0,
        leadingWidth: 53.0,
        leading: 
             GestureDetector(
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
        title:
                var canEdit = false;
                var memberId = '';
                String? icon = '';
                var isPrivate = false;
                int? membersCount = 0;
             
                 ChatHeader(
                  isDirect: false,// parentChannel is Direct,
                  isPrivate: isPrivate,
                  userId: memberId,
                  name: parentChannel!.name,
                  icon: icon,
                  membersCount: membersCount,
                  onTap: canEdit ? () => _goEdit(context, state) : null,
                ), 
      ),
      body: 
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    thickness: 1.0,
                    height: 1.0,
                    color: Color(0xffEEEEEE),
                  ),
                    SizedBox(
                      height: Dim.hm4,
                      width: Dim.hm4,
                      child: Padding(
                        padding: EdgeInsets.all(Dim.widthMultiplier),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  MessagesGroupedList<T>(),
                  BlocBuilder<DraftBloc, DraftState>(
                    buildWhen: (_, current) =>
                        current is DraftLoaded || current is DraftReset,
                    builder: (_, state) {
                      if (state is DraftLoaded &&
                          state.type != DraftType.thread) {
                        draft = state.draft;
                        // print('DRAFT IS LOADED: $draft');
                      } else if (state is DraftReset) {
                        draft = '';
                      }

                      final channelId = messagesState.parentChannel!.id;
                      if (messagesState.parentChannel is Channel) {
                        draftType = DraftType.channel;
                      } else if (messagesState.parentChannel is Direct) {
                        draftType = DraftType.direct;
                      }

                      return BlocBuilder<ThreadMessagesCubit, MessagesState>(
                        bloc: Get.find<ThreadMessagesCubit>(),
                        builder: (ctx, state) {
                            create: (BuildContext context) => FileUploadBloc(),
                            child: ComposeBar(
                              autofocus: state is MessageEditing,
                              initialText: state is MessageEditing
                                  ? state.originalStr
                                  : draft,
                              onMessageSend: state is MessageEditing
                                  ? state.onMessageEditComplete as dynamic
                                      Function(String, BuildContext)?
                                  : (content) async {
                                    
                                final uploadState = Get.find<FileCubit>().state;

                                final List<File> attachments; 

                                      if (uploadState is FileUploadSuccess) {
                                         attachments =  uploadState.files;
                                      // add check for messages chat type
                                      Get.find<ThreadMessagesCubit>().send(originalStr: content, threadId: ,attachments: attachments);
                                      Get.find<ChannelMessagesCubit>().send(originalStr: content,threadId: ,attachments: attachments)
                                      }
                                      // add check for messages chat type
                                      Get.find<ThreadMessagesCubit>().send(originalStr: content, threadId: );
                                      Get.find<ChannelMessagesCubit>().send(originalStr: content,threadId: )
                                     
                                    },
                              onTextUpdated: state is MessageEditing
                                  ? (text, ctx) {}
                                  : (text, ctx) {
                                      context.read<DraftBloc>().add(
                                            UpdateDraft(
                                              id: channelId,
                                              type: draftType,
                                              draft: text,
                                            ),
                                          );
                                    },
                            ),
                          
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
  /*void _goEdit(BuildContext context, MessagesState state) async {
    final params = await openEditChannel(context, state.parentChannel as Channel);
    if (params != null && params.length > 0) {
      final editingState = params.first;
      if (editingState is EditChannelDeleted) {
        Navigator.of(context).maybePop();
      }
    }*/
  }