import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/blocs/message_edit_bloc/message_edit_bloc.dart';
import 'package:twake/blocs/messages_bloc/messages_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/channel.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';
import 'package:twake/widgets/common/text_avatar.dart';
import 'package:twake/widgets/message/message_edit_field.dart';
import 'package:twake/widgets/message/messages_grouped_list.dart';
import 'package:twake/utils/navigation.dart';

class MessagesPage<T extends BaseChannelBloc> extends StatelessWidget {
  const MessagesPage();

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
            return BackButton(
              onPressed: () {
                if (draftType != null) {
                  if (draft.isNotEmpty) {
                    context.read<DraftBloc>().add(SaveDraft(
                          id: channelId,
                          type: draftType,
                          draft: draft,
                        ));
                  } else {
                    context
                        .read<DraftBloc>()
                        .add(ResetDraft(id: channelId, type: draftType));
                  }
                  Navigator.of(context).pop();
                }
              },
            );
          },
        ),
        title: BlocBuilder<MessagesBloc<T>, MessagesState>(
          builder: (ctx, state) => GestureDetector(
            onTap: () => openEditChannel(context, state.parentChannel.id),
            child: Row(
              children: [
                if ((state.parentChannel is Direct))
                  StackedUserAvatars((state.parentChannel as Direct).members),
                if (state.parentChannel is Channel)
                  TextAvatar(
                    state.parentChannel.icon,
                  ),
                SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          state.parentChannel.name,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff444444),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 6),
                        if (state.parentChannel is Channel &&
                            (state.parentChannel as Channel).visibility != null &&
                            (state.parentChannel as Channel).visibility ==
                                'private')
                          Icon(Icons.lock_outline,
                              size: 15.0, color: Color(0xff444444)),
                      ],
                    ),
                    if (state.parentChannel is Channel)
                      Text(
                        '${state.parentChannel.membersCount ?? 'No'} members',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff92929C),
                        ),
                      ),
                    if (state.parentChannel is Direct &&
                        state.parentChannel.membersCount > 2)
                      Text(
                        '${state.parentChannel.membersCount} members',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff92929C),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<MessagesBloc<T>, MessagesState>(
            builder: (ctx, messagesState) {
          return BlocProvider<MessageEditBloc>(
            create: (ctx) => MessageEditBloc(),
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
                      builder: (ctx, state) => MessageEditField(
                        key: UniqueKey(),
                        autofocus: state is MessageEditing,
                        initialText:
                            state is MessageEditing ? state.originalStr : draft,
                        onMessageSend: state is MessageEditing
                            ? state.onMessageEditComplete
                            : (content) {
                                BlocProvider.of<MessagesBloc<T>>(context).add(
                                  SendMessage(content: content),
                                );
                                context.read<DraftBloc>().add(
                                    ResetDraft(id: channelId, type: draftType));
                              },
                        onTextUpdated: state is MessageEditing
                            ? (text) {}
                            : (text) {
                                context.read<DraftBloc>().add(UpdateDraft(
                                      id: channelId,
                                      type: draftType,
                                      draft: text,
                                    ));
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
