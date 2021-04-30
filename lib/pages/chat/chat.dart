import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_cubit.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_state.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_bloc.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/message_edit_bloc/message_edit_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/pages/chat/chat_header.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/pages/chat/message_edit_field.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/utils/twacode.dart';

class Chat<T extends BaseChannelBloc> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String draft = '';
    String channelId;
    DraftType draftType;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        shadowColor: Colors.grey[300],
        toolbarHeight: 60.0,
        leadingWidth: 53.0,
        leading: BlocBuilder<DraftBloc, DraftState>(
          buildWhen: (_, current) =>
              current is DraftUpdated || current is DraftReset,
          builder: (context, state) {
            if (state is DraftUpdated && state.type != DraftType.thread) {
              channelId = state.id;
              draft = state.draft;
              draftType = state.type;
            }
            if (state is DraftReset) {
              draft = '';
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (draftType != null) {
                  if (draft.isNotEmpty) {
                    context.read<DraftBloc>().add(
                          SaveDraft(
                            id: channelId,
                            type: draftType,
                            draft: draft,
                          ),
                        );
                  } else {
                    context
                        .read<DraftBloc>()
                        .add(ResetDraft(id: channelId, type: draftType));
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xff004dff),
                ),
              ),
            );
          },
        ),
        title: BlocBuilder<MessagesBloc<T>, MessagesState>(
          builder: (_, state) {
            BaseChannel parentChannel = T is Channel ? Channel() : Direct();

            if ((state is MessagesLoaded || state is MessagesEmpty) &&
                state.parentChannel.id == ProfileBloc.selectedChannelId) {
              parentChannel = state.parentChannel;
            }
            return BlocBuilder<EditChannelCubit, EditChannelState>(
              builder: (context, editState) {
                var canEdit = false;
                var memberId = '';
                var icon = '';
                var isPrivate = false;
                var membersCount = 0;

                if (parentChannel is Channel) {
                  isPrivate = parentChannel.visibility == 'private';
                  icon = parentChannel.icon;
                  membersCount = parentChannel.membersCount;

                  // Possible permissions:
                  // ['UPDATE_NAME', 'UPDATE_DESCRIPTION',
                  // 'ADD_MEMBER', 'REMOVE_MEMBER',
                  // 'UPDATE_PRIVACY','DELETE_CHANNEL']
                  final permissions = parentChannel.permissions;

                  if (permissions.contains('UPDATE_NAME') ||
                      permissions.contains('UPDATE_DESCRIPTION') ||
                      permissions.contains('ADD_MEMBER') ||
                      permissions.contains('REMOVE_MEMBER') ||
                      permissions.contains('UPDATE_PRIVACY') ||
                      permissions.contains('DELETE_CHANNEL')) {
                    canEdit = true;
                  } else {
                    canEdit = false;
                  }
                } else if (parentChannel is Direct &&
                    parentChannel.members != null) {
                  final userId = ProfileBloc.userId;
                  memberId =
                      parentChannel.members.firstWhere((id) => id != userId);
                }

                if (editState is EditChannelSaved) {
                  context
                      .read<MemberCubit>()
                      .fetchMembers(channelId: channelId);
                }

                return ChatHeader(
                  isDirect: parentChannel is Direct,
                  isPrivate: isPrivate,
                  userId: memberId,
                  name: parentChannel.name,
                  icon: icon,
                  membersCount: membersCount,
                  onTap: canEdit ? () => _goEdit(context, state) : null,
                );
              },
            );
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<MessagesBloc<T>, MessagesState>(
          builder: (_, messagesState) {
            return BlocProvider<MessageEditBloc>(
              create: (_) => MessageEditBloc(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    thickness: 1.0,
                    height: 1.0,
                    color: Color(0xffEEEEEE),
                  ),
                  if (messagesState is MoreMessagesLoading &&
                      !(messagesState is ErrorLoadingMoreMessages))
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

                      final channelId = messagesState.parentChannel.id;
                      if (messagesState.parentChannel is Channel) {
                        draftType = DraftType.channel;
                      } else if (messagesState.parentChannel is Direct) {
                        draftType = DraftType.direct;
                      }

                      return BlocBuilder<MessageEditBloc, MessageEditState>(
                        builder: (ctx, state) {
                          return BlocProvider(
                            create: (BuildContext context) => FileUploadBloc(),
                            child: MessageEditField(
                              autofocus: state is MessageEditing,
                              initialText: state is MessageEditing
                                  ? state.originalStr
                                  : draft,
                              onMessageSend: state is MessageEditing
                                  ? state.onMessageEditComplete
                                  : (content, context) async {
                                      content =
                                          await BlocProvider.of<MentionsCubit>(
                                                  context)
                                              .completeMentions(content);
                                      List<dynamic> twacode =
                                          TwacodeParser(content).message;

                                      final uploadState =
                                          BlocProvider.of<FileUploadBloc>(
                                                  context)
                                              .state;
                                      if (uploadState is FileUploaded) {
                                        if (twacode.isNotEmpty) {
                                          twacode.add({
                                            'start': '\n',
                                            'end': '',
                                            'content': [],
                                          });
                                        }
                                        twacode.add(
                                          {
                                            "type": "nop",
                                            "content":
                                                uploadState.files.map((uf) {
                                              return {
                                                "type": "file",
                                                "mode": "preview",
                                                "content": uf.id,
                                                "metadata": {
                                                  "size": uf.size,
                                                  "name": uf.filename,
                                                  "preview": uf.preview,
                                                  "download": uf.download
                                                }
                                              };
                                            }).toList(),
                                          },
                                        );
                                      }

                                      BlocProvider.of<MessagesBloc<T>>(context)
                                          .add(
                                        SendMessage(
                                            content: content,
                                            prepared: twacode),
                                      );
                                      BlocProvider.of<FileUploadBloc>(context)
                                          .add(ClearUploads());
                                      context.read<DraftBloc>().add(
                                            ResetDraft(
                                              id: channelId,
                                              type: draftType,
                                            ),
                                          );
                                    },
                              onTextUpdated: state is MessageEditing
                                  ? (text) {}
                                  : (text) {
                                      context.read<DraftBloc>().add(
                                            UpdateDraft(
                                              id: channelId,
                                              type: draftType,
                                              draft: text,
                                            ),
                                          );
                                    },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _goEdit(BuildContext context, MessagesState state) async {
    final params = await openEditChannel(context, state.parentChannel);
    if (params != null && params.length > 0) {
      final editingState = params.first;
      if (editingState is EditChannelDeleted) {
        Navigator.of(context).maybePop();
      }
    }
  }
}
