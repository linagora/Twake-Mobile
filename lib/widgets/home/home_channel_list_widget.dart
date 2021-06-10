import 'package:flutter/material.dart';
import 'package:twake/widgets/home/home_channel_tile.dart';

class HomeChannelListWidget extends StatelessWidget {
  const HomeChannelListWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 1,
            color: Color(0xffd8d8d8),
          );
        },
        itemCount: 15,
        itemBuilder: (context, index) {
          return HomeChannelTile();
        },
      ),
    );
  }
}
