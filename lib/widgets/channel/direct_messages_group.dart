import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/widgets/channel/direct_tile.dart';
import 'package:twake/widgets/common/main_page_title.dart';

class DirectMessagesGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectsBloc, ChannelState>(
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainPageTitle(
              title: 'Direct Messages',
              isDirect: true,
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
