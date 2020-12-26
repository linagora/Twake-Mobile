import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/widgets/channel/direct_tile.dart';

class DirectMessagesGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirectsBloc, ChannelState>(
      builder: (ctx, state) {
        if (state is DirectsLoaded) {
          return Column(
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
              ...state.directs.map((d) => DirectTile(d)).toList(),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
