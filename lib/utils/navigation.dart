import 'package:flutter/material.dart';
import 'package:twake/blocs/base_channel_bloc/base_channel_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_state.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspaces_bloc.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/pages/edit_channel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/pages/server_configuration.dart';

void openChannel(BuildContext context, String channelId) =>
    _open<ChannelsBloc>(context, channelId);

void openDirect(BuildContext context, String channelId) =>
    _open<DirectsBloc>(context, channelId);

Future<void> _open<T extends BaseChannelBloc>(BuildContext context, String channelId) async {
  context.read<T>().add(ChangeSelectedChannel(channelId));
  context.read<MemberCubit>().fetchMembers(channelId: channelId);
  // print('On open: $channelId');
  await Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => MessagesPage<T>(),
      ))
      .then((r) => handleError(r, context));

  ProfileBloc.selectedChannelId = null;
  ProfileBloc.selectedThreadId = null;
}

void selectWorkspace(BuildContext context, String workspaceId) {
  context.read<WorkspacesBloc>().add(ChangeSelectedWorkspace(workspaceId));
}

Future<List<EditChannelState>> openEditChannel(
    BuildContext context, Channel channel) {
  return Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => EditChannel(channel: channel),
  ));
  // .then((r) => handleError(r, context));
}

void openChooseServer(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => ServerConfiguration(),
      ))
      .then((r) => handleError(r, context));
}

void handleError(dynamic r, BuildContext context) {
  if (r is bool && r) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No connection to internet'),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }
}
