import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_cubit.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_state.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/blocs/message_edit_bloc/message_edit_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/base_channel.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/pages/feed/user_thumbnail.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/widgets/common/channel_title.dart';
import 'package:twake/pages/chat/message_edit_field.dart';
import 'package:twake/pages/chat/messages_grouped_list.dart';
import 'package:twake/utils/navigation.dart';

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
        toolbarHeight: Dim.heightPercent((kToolbarHeight * 0.15).round()),
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
          builder: (ctx, state) {
            BaseChannel parentChannel = T is Channel ? Channel() : Direct();
            var _canEdit = false;
            var memberId = '';

            if ((state is MessagesLoaded || state is MessagesEmpty) &&
                state.parentChannel.id == ProfileBloc.selectedChannelId) {
              parentChannel = state.parentChannel;

              if (parentChannel is Channel) {
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
                  _canEdit = true;
                } else {
                  _canEdit = false;
                }
              } else if (parentChannel is Direct &&
                  parentChannel.members != null) {
                final userId = ProfileBloc.userId;
                memberId =
                    parentChannel.members.firstWhere((id) => id != userId);
              }
            }

            // print('MessagesBloc state: $state');
            // print('Parent channel current value: $parentChannel');

            return BlocBuilder<EditChannelCubit, EditChannelState>(
              builder: (context, editState) {
                if (editState is EditChannelSaved) {
                  context
                      .read<MemberCubit>()
                      .fetchMembers(channelId: channelId);
                  if (parentChannel is Channel &&
                      parentChannel.id == editState.channelId) {
                    parentChannel.icon = editState.icon;
                    parentChannel.name = editState.name;
                    parentChannel.description = editState.description;
                  }
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _canEdit ? () => _goEdit(context, state) : null,
                  child: Container(
                    child: Row(
                      children: [
                        if (parentChannel is Direct)
                          UserThumbnail(
                            userId: memberId,
                            size: 36.0,
                          ),
                        if (parentChannel is Channel)
                          ShimmerLoading(
                            key: ValueKey<String>('channel_icon'),
                            isLoading: parentChannel.icon == null ||
                                parentChannel.icon.isEmpty,
                            width: 32.0,
                            height: 32.0,
                            child: TextAvatar(parentChannel.icon ?? ''),
                          ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerLoading(
                                key: ValueKey<String>('name'),
                                isLoading: parentChannel.name == null,
                                width: 60.0,
                                height: 10.0,
                                child: ChannelTitle(
                                  name: parentChannel.name ?? '',
                                  isPrivate: (parentChannel is Channel) &&
                                      parentChannel.visibility != null &&
                                      parentChannel.visibility == 'private',
                                ),
                              ),
                              SizedBox(height: 4),
                              if (parentChannel is Channel)
                                ShimmerLoading(
                                  key: ValueKey<String>('membersCount'),
                                  isLoading: parentChannel.membersCount == null,
                                  width: 50,
                                  height: 10,
                                  child: Text(
                                    parentChannel.membersCount == null
                                        ? ''
                                        : '${parentChannel.membersCount > 0 ? parentChannel.membersCount : 'No'} members',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff92929C),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                      ],
                    ),
                  ),
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
                    builder: (context, state) {
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
                          return MessageEditField(
                            autofocus: state is MessageEditing,
                            initialText: state is MessageEditing
                                ? state.originalStr
                                : draft,
                            onMessageSend: state is MessageEditing
                                ? state.onMessageEditComplete
                                : (content) {
                                    BlocProvider.of<MessagesBloc<T>>(context)
                                        .add(
                                      SendMessage(content: content),
                                    );
                                    context.read<DraftBloc>().add(
                                          ResetDraft(
                                              id: channelId, type: draftType),
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
