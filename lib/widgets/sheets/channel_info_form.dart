import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_bloc.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_state.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_event.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/widgets/sheets/button_field.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/widgets/sheets/switch_field.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelInfoForm extends StatefulWidget {
  @override
  _ChannelInfoFormState createState() => _ChannelInfoFormState();
}

class _ChannelInfoFormState extends State<ChannelInfoForm> {
  final _channelNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _channelNameFocusNode = FocusNode();
  final _channelDescriptionFocusNode = FocusNode();

  var _canGoNext = false;
  var _channelType = ChannelType.public;
  var _participants = <String>[];
  var _automaticallyAddNew = true;

  @override
  void initState() {
    super.initState();
    _channelNameController.addListener(() {
      final channelName = _channelNameController.text;
      _batchUpdateState(name: channelName);
      if (channelName.isNotReallyEmpty && !_canGoNext) {
        setState(() {
          _canGoNext = true;
        });
      } else if (channelName.isReallyEmpty && _canGoNext) {
        setState(() {
          _canGoNext = false;
        });
      }
    });

    _descriptionController.addListener(() {
      _batchUpdateState(description: _descriptionController.text);
    });
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    _descriptionController.dispose();
    _channelNameFocusNode.dispose();
    _channelDescriptionFocusNode.dispose();
    super.dispose();
  }

  void _batchUpdateState({
    String name,
    String description,
    ChannelType type,
    List<String> participants,
    bool automaticallyAddNew,
  }) {
    context.read<AddChannelBloc>().add(Update(
          name: name ?? _channelNameController.text,
          description: description ?? _descriptionController.text,
          type: type ?? _channelType,
          participants: participants ?? _participants,
          automaticallyAddNew: automaticallyAddNew ?? _automaticallyAddNew,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MemberCubit, MemberState>(
          listener: (context, state) {
            if (state is MembersUpdated) {
              String channelId = state.channelId;
              openChannel(context, channelId);
            }
          },
        ),
        BlocListener<SheetBloc, SheetState>(
          listener: (context, state) {
            if (state is SheetShouldClear) {
              _channelNameController.clear();
              _descriptionController.clear();
              FocusScope.of(context).requestFocus(new FocusNode());
              context.read<AddChannelBloc>().add(Clear());
            }
          },
        ),
      ],
      child: BlocConsumer<AddChannelBloc, AddChannelState>(
          listener: (context, state) {
        if (state is Created) {
          if (_channelType == ChannelType.private &&
              _participants.length != 0) {
            context
                .read<MemberCubit>()
                .updateMembers(channelId: state.id, members: _participants);
          }
          // Reload channels
          context.read<ChannelsBloc>().add(ReloadChannels(forceFromApi: true));
          // Reload directs
          context.read<DirectsBloc>().add(ReloadChannels(forceFromApi: true));
          // Close sheet
          context.read<SheetBloc>().add(CloseSheet());
          // Clear sheet
          context.read<SheetBloc>().add(ClearSheet());
          // Redirect user to created channel
          if (_channelType != ChannelType.private ||
              _participants.length == 0) {
            String channelId = state.id;
            openChannel(context, channelId);
          }
        } else if (state is Error) {
          // Show an error
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
              state.message,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            duration: Duration(seconds: 2),
          ));
        }
      }, buildWhen: (_, current) {
        return (current is Updated || current is Creation);
      }, builder: (context, state) {
        bool createIsBlocked = state is Creation;
        if (state is Updated) {
          _channelType = state.repository?.type;
          _participants = state.repository?.members;
          _automaticallyAddNew = state.repository.def;
        }

        return Column(
          children: [
            SheetTitleBar(
              title: 'New Channel',
              leadingTitle: 'Close',
              leadingAction: () {
                context.read<SheetBloc>().add(CloseSheet());
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              trailingTitle: 'Create',
              trailingAction: createIsBlocked || !_canGoNext
                  ? null
                  : () => context.read<AddChannelBloc>().add(Create()),
            ),
            SizedBox(height: 16),
            SheetTextField(
              hint: 'Channel name',
              controller: _channelNameController,
              focusNode: _channelNameFocusNode,
            ),
            SizedBox(height: 8),
            HintLine(
              text: 'Please provide a channel name and optional channel icon',
            ),
            SizedBox(height: 20),
            SheetTextField(
              hint: 'Channel description',
              controller: _descriptionController,
              focusNode: _channelDescriptionFocusNode,
            ),
            SizedBox(height: 8),
            HintLine(
              text: 'Please provide an optional description for your channel',
            ),
            SizedBox(height: 30),
            HintLine(
              text: 'CHANNEL TYPE',
              isLarge: true,
            ),
            SizedBox(height: 6),
            ChannelTypesContainer(
              type: _channelType,
              onPublicTap: () => _batchUpdateState(type: ChannelType.public),
              onPrivateTap: () => _batchUpdateState(type: ChannelType.private),
            ),
            SizedBox(height: 8),
            HintLine(
              text: _channelType != ChannelType.direct
                  ? 'Public channels can be found by everyone, though private can only be joined by invitation'
                  : 'Direct channels involve correspondence between selected members',
            ),
            if (_channelType == ChannelType.private) SizedBox(height: 8),
            if (_channelType == ChannelType.private)
              ParticipantsButton(count: _participants.length),
            SizedBox(height: 8),
            if (_channelType == ChannelType.public)
              SwitchField(
                title: 'Automatically add new users',
                value: _automaticallyAddNew,
                onChanged: (value) =>
                    _batchUpdateState(automaticallyAddNew: value),
              ),
            if (_channelType == ChannelType.private) SizedBox(),
            HintLine(
              text: _channelType != ChannelType.private
                  ? (_channelType != ChannelType.direct
                      ? 'Only available for public channels'
                      : 'Only available for direct channels')
                  : '',
            ),
          ],
        );
      }),
    );
  }
}

class ChannelTypesContainer extends StatelessWidget {
  final ChannelType type;
  final Function onPublicTap;
  final Function onPrivateTap;

  const ChannelTypesContainer({
    Key key,
    @required this.type,
    @required this.onPublicTap,
    @required this.onPrivateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(
          thickness: 0.5,
          height: 0.5,
          color: Colors.black.withOpacity(0.2),
        ),
        SelectableItem(
          title: 'Public',
          selected: type == ChannelType.public,
          onTap: onPublicTap,
        ),
        SelectableItem(
          title: 'Private',
          selected: type == ChannelType.private,
          onTap: onPrivateTap,
        ),
      ],
    );
  }
}

class SelectableItem extends StatelessWidget {
  final String title;
  final bool selected;
  final Function onTap;

  const SelectableItem({
    Key key,
    @required this.title,
    @required this.selected,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.0,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    if (selected)
                      Icon(
                        CupertinoIcons.check_mark,
                        color: Color(0xff3840F7),
                      ),
                  ],
                ),
              ),
            ),
            Divider(
              indent: 15.0,
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantsButton extends StatelessWidget {
  final int count;

  const ParticipantsButton({Key key, this.count = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<AddChannelBloc>()
          .add(SetFlowStage(FlowStage.participants)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
        child: ButtonField(
          title: 'Added participants',
          trailingTitle: count > 0 ? '$count' : 'Add',
          hasArrow: count > 0,
        ),
      ),
    );
  }
}
