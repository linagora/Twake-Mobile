import 'package:flutter/material.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';

class AddChannelContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: NewChannelForm(),
    );
  }
}

class NewChannelForm extends StatefulWidget {
  @override
  _NewChannelFormState createState() => _NewChannelFormState();
}

class _NewChannelFormState extends State<NewChannelForm> {
  var _channelName = '';
  var _description = '';
  var _groupName = '';
  var canGoNext = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SheetTitleBar(
          title: 'New Channel',
          trailingTitle: 'Next',
          trailingAction: canGoNext ? () => print('GO!') : null,
        )
      ],
    );
  }
}
