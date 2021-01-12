import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/widgets/channel/channel_tile.dart';

class ChannelsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelsBloc, ChannelState>(
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Channels',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ],
            ),
            if (state is ChannelsLoaded)
              ...state.channels.map((c) => ChannelTile(c)).toList(),
            if (state is ChannelsEmpty)
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Text('You have no channels yet'),
              ),
            if (state is ChannelsLoading) CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}
