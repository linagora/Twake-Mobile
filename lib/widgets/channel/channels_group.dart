import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/states/channel_state.dart';
import 'package:twake/widgets/channel/channel_tile.dart';

class ChannelsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsBloc, ChannelState>(
      builder: (ctx, state) {
        if (state is ChannelsLoaded)
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    'Channels',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ],
              ),
              ...state.channels.map((c) => ChannelTile(c)).toList(),
            ],
          );
        else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
