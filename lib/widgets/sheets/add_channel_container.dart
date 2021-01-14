import 'package:flutter/material.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/sheets/channel_name_container.dart';
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
      ],
    );
  }
}
