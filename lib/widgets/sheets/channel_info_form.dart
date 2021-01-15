import 'package:flutter/material.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/channel_info_text_form.dart';
import 'package:twake/widgets/sheets/channel_name_container.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelInfoForm extends StatefulWidget {
  @override
  _ChannelInfoFormState createState() => _ChannelInfoFormState();
}

class _ChannelInfoFormState extends State<ChannelInfoForm> {
  var _canGoNext = false;

  final _channelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _groupNameController = TextEditingController();

  final _channelNameFocusNode = FocusNode();
  final _channelDescriptionFocusNode = FocusNode();
  final _groupNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _groupNameFocusNode.addListener(() {
      print(_groupNameFocusNode.hasFocus);
      setState(() {});
    });

    _channelNameController.addListener(() {
      context
          .read<AddChannelBloc>()
          .add(Update(name: _channelNameController.text));
      if (_channelNameController.text.isNotEmpty) {
        setState(() {
          _canGoNext = true;
        });
      }
    });

    _descriptionController.addListener(() {
      context
          .read<AddChannelBloc>()
          .add(Update(description: _descriptionController.text));
    });

    _groupNameController.addListener(() {
      context
          .read<AddChannelBloc>()
          .add(Update(groupName: _groupNameController.text));
    });
  }

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
          trailingAction: _canGoNext
              ? () => context
                  .read<AddChannelBloc>()
                  .add(SetFlowStage(FlowStage.type))
              : null,
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
          padding: const EdgeInsets.only(left: 14.0, right: 7),
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
          padding: const EdgeInsets.only(left: 14.0, right: 10),
          color: Colors.white,
          child: ChannelInfoTextForm(
            hint: 'Channel group name',
            controller: _groupNameController,
            focusNode: _groupNameFocusNode,
            leadingAction: () => _groupNameController.clear(),
            trailingAction: () => context
                .read<AddChannelBloc>()
                .add(SetFlowStage(FlowStage.groups)),
          ),
        ),
        SizedBox(height: 8),
        HintLine(
          text:
              'You can add your channel to an existing group or create a new one',
        ),
      ],
    );
  }
}
