import 'package:flutter/material.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/pages/edit_channel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void openChannel(BuildContext context, String channelId) =>
    _open<ChannelsBloc>(context, channelId);

void openDirect(BuildContext context, String channelId) =>
    _open<DirectsBloc>(context, channelId);

void _open<T extends BaseChannelBloc>(BuildContext context, String channelId) {
  context.read<T>().add(ChangeSelectedChannel(channelId));
  context.read<MemberCubit>().fetchMembers(channelId: channelId);
  Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => MessagesPage<T>(),
      ))
      .then((r) => handleError(r, context));
}

void selectWorkspace(BuildContext context, String workspaceId) {
  context.read<WorkspacesBloc>().add(ChangeSelectedWorkspace(workspaceId));
}

void openEditChannel(BuildContext context, Channel channel) {
  Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => EditChannel(channel: channel),
      ))
      .then((r) => handleError(r, context));
}

void handleError(dynamic r, BuildContext context) {
  if (r is bool && r) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('No connection to internet'),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }
}
