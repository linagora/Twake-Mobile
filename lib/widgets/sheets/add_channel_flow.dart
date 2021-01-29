import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/add_channel/add_channel_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:twake/widgets/sheets/channel_info_form.dart';
import 'package:twake/widgets/sheets/channel_participants_list.dart';

class AddChannelFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      create: (_) => UserBloc(ProfileBloc.userId),
      child: BlocBuilder<AddChannelBloc, AddChannelState>(
        buildWhen: (previous, current) => current is FlowTypeSet,
        builder: (context, state) {
          if (state is FlowTypeSet) {
            if (state.isDirect) {
              return ChannelParticipantsList();
            } else {
              return ChannelInfoForm();
            }
          } else {
            return ChannelInfoForm();
          }
        },
      ),
    );
  }
}
