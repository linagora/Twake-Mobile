import 'package:flutter/material.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/widgets/sheets/add_channel_flow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableScrollable extends StatelessWidget {
  const DraggableScrollable({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        double extent = notification.extent;
        if (extent < 0.3) {
          // ignore: close_sinks
          var bloc = context.read<SheetBloc>();
          if (bloc.state != SheetShouldOpen()) {
            bloc.add(CloseSheet());
          }
        }
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return ClipRRect(
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffefeef3),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: AddChannelFlow(),
              ),
            ),
          );
        },
      ),
    );
  }
}
