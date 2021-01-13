import 'package:flutter/material.dart';

enum DraggableScrollableFlow {
  channel,
  direct,
}

class DraggableScrollable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        builder: (BuildContext context, ScrollController scrollController) {
      return Container(
        color: Colors.blue[100],
        child: ListView.builder(
          controller: scrollController,
          itemCount: 25,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(title: Text('Item $index'));
          },
        ),
      );
    });
  }
}
