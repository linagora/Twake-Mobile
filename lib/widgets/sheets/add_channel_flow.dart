import 'package:flutter/material.dart';
import 'package:twake/widgets/sheets/channel_name_container.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/new_channel_form.dart';

class AddChannelFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children: [
        NewChannelForm(),
      ],
    );
  }
}
