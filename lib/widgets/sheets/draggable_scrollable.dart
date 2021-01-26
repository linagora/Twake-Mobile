import 'package:flutter/material.dart';
import 'package:twake/widgets/sheets/add_channel_flow.dart';

class DraggableScrollable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          child: AddChannelFlow(),
        ),
      ),
    );
  }
}
