import 'package:flutter/material.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/widgets/sheets/add_channel_flow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableScrollable extends StatefulWidget {
  final double initialSize;

  const DraggableScrollable({Key key, this.initialSize = 0.9})
      : super(key: key);

  @override
  _DraggableScrollableState createState() => _DraggableScrollableState();
}

class _DraggableScrollableState extends State<DraggableScrollable> {
  double _initialSize;

  @override
  void initState() {
    super.initState();
    _initialSize = widget.initialSize;
  }

  @override
  void didUpdateWidget(covariant DraggableScrollable oldWidget) {
    if (oldWidget.initialSize != widget.initialSize) {
      _initialSize = widget.initialSize;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        double extent = notification.extent;
        // ignore: close_sinks
        var bloc = context.read<SheetBloc>();
        if (extent < 0.3 &&
            bloc.state is! SheetShouldOpen) {
          bloc.add(CloseSheet());
        }
        return true;
      },
      child: BlocBuilder<SheetBloc, SheetState>(
          buildWhen: (_, current) => current is SheetShouldReset,
          builder: (context, state) {
            if (state is SheetShouldReset) {
              DraggableScrollableActuator.reset(context);
            }
            return DraggableScrollableSheet(
              key: UniqueKey(),
              initialChildSize: _initialSize,
              maxChildSize: 0.9,
              builder:
                  (BuildContext context, ScrollController scrollController) {
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
            );
          }),
    );
  }
}
