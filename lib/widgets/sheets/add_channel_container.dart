import 'package:flutter/material.dart';
import 'package:twake/widgets/sheets/channel_name_container.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/widgets/sheets/channel_info_text_form.dart';

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
  var _canGoNext = false;

  final _channelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _groupNameController = TextEditingController();

  final _channelNameFocusNode = FocusNode();
  final _channelDescriptionFocusNode = FocusNode();
  final _groupNameFocusNode = FocusNode();

  @override
  void dispose() {
    _channelNameController.dispose();
    _descriptionController.dispose();
    _groupNameController.dispose();
    _channelNameFocusNode.dispose();
    _channelDescriptionFocusNode.dispose();
    _groupNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SheetTitleBar(
          title: 'New Channel',
          trailingTitle: 'Next',
          trailingAction: _canGoNext ? () => print('GO!') : null,
        ),
        SizedBox(height: 16),
        ChannelNameContainer(
          controller: _channelNameController,
          focusNode: _channelNameFocusNode,
        ),
        SizedBox(height: 8),
        HintLine(
          text: 'Please provide a channel name and optional channel icon',
        ),
        SizedBox(height: 20),
        Container(
          height: 44.0,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          color: Colors.white,
          child: ChannelInfoTextForm(
            hint: 'Channel description',
            controller: _descriptionController,
            focusNode: _channelDescriptionFocusNode,
          ),
        ),
        SizedBox(height: 8),
        HintLine(
          text: 'Please provide an optional description for your channel',
        ),
        SizedBox(height: 20),
        Container(
          height: 44.0,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          color: Colors.white,
          child: ChannelInfoTextForm(
            hint: 'Channel group name',
            controller: _groupNameController,
            focusNode: _groupNameFocusNode,
            trailingAction: () => print('SHOW GROUPS!'),
          ),
        ),
        SizedBox(height: 8),
        HintLine(
          text: 'You can add your channel to an existing group or create a new one',
        ),
      ],
    );
  }
}
