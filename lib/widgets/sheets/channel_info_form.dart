import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/channel_info_text_form.dart';
import 'package:twake/widgets/sheets/channel_name_container.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel/add_channel_bloc.dart';
import 'package:twake/utils/extensions.dart';
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
      final channelName = _channelNameController.text;
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
    return BlocListener<SheetBloc, SheetState>(
      listener: (context, state) {
        if (state is SheetShouldClear) {
          _channelNameController.clear();
          _descriptionController.clear();
          _groupNameController.clear();
          FocusScope.of(context).requestFocus(new FocusNode());
          context.read<AddChannelBloc>().add(Clear());
        }
      },
      child: BlocConsumer<AddChannelBloc, AddChannelState>(
          listener: (context, state) {
            if (state is Created) {
              // Reload channels
              context.read<ChannelsBloc>().add(ReloadChannels(forceFromApi: true));
              // Reload directs
              context.read<DirectsBloc>().add(ReloadChannels(forceFromApi: true));
              // Close sheet
              context.read<SheetBloc>().add(CloseSheet());
              // Clear sheet
              context.read<SheetBloc>().add(ClearSheet());
              // Return to initial page
              context.read<AddChannelBloc>().add(SetFlowStage(FlowStage.info));
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
          },
          buildWhen: (_, current) {
            return (current is Updated ||
                current is StageUpdated ||
                current is Creation);
          },
        builder: (context, state) {
          bool createIsBlocked = state is Creation;

          var channelType = ChannelType.public;
          if (state is Updated) {
            channelType = state.repository?.type;
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
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.only(left: 14.0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'CHANNEL TYPE',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),
              SizedBox(height: 6),
              ChannelTypesContainer(type: channelType),
              SizedBox(height: 8),
              HintLine(
                text: channelType != ChannelType.direct
                    ? 'Public channels can be found by everyone, though private can only be joined by invitation'
                    : 'Direct channels involve correspondence between selected members',
              ),
              if (channelType == ChannelType.public) AddAllSwitcher(),
              if (channelType == ChannelType.private) SizedBox(),
              // if (channelType == ChannelType.direct) ParticipantsButton(),
              HintLine(
                text: channelType != ChannelType.private
                    ? (channelType != ChannelType.direct
                    ? 'Only available for public channels'
                    : 'Only available for direct channels')
                    : '',
              ),
            ],
          );
        }
      ),
    );
  }
}

class ChannelTypesContainer extends StatelessWidget {
  final ChannelType type;

  const ChannelTypesContainer({
    Key key,
    @required this.type,
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
          onTap: () => context
              .read<AddChannelBloc>()
              .add(Update(type: ChannelType.public)),
        ),
        SelectableItem(
          title: 'Private',
          selected: type == ChannelType.private,
          onTap: () => context
              .read<AddChannelBloc>()
              .add(Update(type: ChannelType.private)),
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
                        color: Color(0xff837cfe),
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<AddChannelBloc>()
          .add(SetFlowStage(FlowStage.participants)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
        child: ParticipantsCommonWidget(
          title: 'Added participants',
          trailingWidget: BlocBuilder<AddChannelBloc, AddChannelState>(
            builder: (context, state) {
              var participantsCount = 0;
              if (state is Updated) {
                final participants = state.repository?.members;
                participantsCount = participants.length;
              }
              return participantsCount > 0
                  ? Row(
                children: [
                  Text(
                    '$participantsCount',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff837cfe),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.forward,
                    color: Color(0xff837cfe),
                  ),
                ],
              )
                  : Text(
                'Add',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff837cfe),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AddAllSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
      child: ParticipantsCommonWidget(
        title: 'Automatically add new users',
        trailingWidget: BlocBuilder<AddChannelBloc, AddChannelState>(
          builder: (context, state) {
            var shouldAddAll = true;
            if (state is Updated) {
              shouldAddAll = state.repository.def;
            }
            return CupertinoSwitch(
              value: shouldAddAll,
              onChanged: (value) {
                context
                    .read<AddChannelBloc>()
                    .add(Update(automaticallyAddNew: value));
              },
            );
          },
        ),
      ),
    );
  }
}

class ParticipantsCommonWidget extends StatelessWidget {
  final String title;
  final Widget trailingWidget;

  const ParticipantsCommonWidget({
    Key key,
    @required this.title,
    @required this.trailingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          Spacer(),
          trailingWidget,
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
