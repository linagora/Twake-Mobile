import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/widgets/channel/direct_tile.dart';

class DirectMessagesGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectsBloc, ChannelState>(
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Direct Messages',
                  style: Theme.of(context).textTheme.headline3,
                ),
                // Expanded(
                // child: Align(
                // alignment: Alignment.centerRight,
                // child: IconButton(
                // onPressed: () {},
                // iconSize: Dim.tm4(),
                // icon: Icon(
                // Icons.add,
                // color: Colors.black,
                // ),
                // ),
                // ),
                // ),
              ],
            ),
            if (state is ChannelsLoaded)
              ...state.channels.map((d) => DirectTile(d)).toList(),
            if (state is ChannelsEmpty)
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Text('You have no direct channels yet'),
              ),
            if (state is ChannelsLoading) CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}
