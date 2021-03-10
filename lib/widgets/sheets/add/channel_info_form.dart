import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
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
import 'package:twake/widgets/common/selectable_avatar.dart';
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
  var _icon = '📄';
  var _emojiVisible = false;

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

    _channelNameFocusNode.addListener(() {
      if (_channelNameFocusNode.hasFocus) {
        _closeKeyboards(context, both: false);
      }
    });

    _channelDescriptionFocusNode.addListener(() {
      if (_channelDescriptionFocusNode.hasFocus) {
        _closeKeyboards(context, both: false);
      }
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
    String icon,
    String name,
    String description,
    ChannelType type,
    List<String> participants,
    bool automaticallyAddNew,
  }) {
    context.read<AddChannelBloc>().add(
          Update(
            icon: icon ?? _icon,
            name: name ?? _channelNameController.text,
            description: description ?? _descriptionController.text,
            type: type ?? _channelType,
            participants: participants ?? _participants,
            automaticallyAddNew: automaticallyAddNew ?? _automaticallyAddNew,
          ),
        );
  }

  void _toggleEmojiBoard() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await Future.delayed(Duration(milliseconds: 150));
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }

  Widget _buildEmojiBoard() {
    return EmojiKeyboard(
      onEmojiSelected: (emoji) {
        _canGoNext = true;
        _icon = emoji.text;
        _batchUpdateState(icon: _icon);
        _toggleEmojiBoard();
      },
      height: MediaQuery.of(context).size.height * 0.35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MemberCubit, MemberState>(
          listener: (context, state) {
            if (state is MembersAdded) {
              String channelId = state.channelId;
              openChannel(context, channelId);
            }
          },
        ),
        BlocListener<SheetBloc, SheetState>(
          listener: (context, state) {
            if (state is SheetShouldClear) {
              _icon = '';
              _channelNameController.clear();
              _descriptionController.clear();
              _participants = [];
              _automaticallyAddNew = true;
              _channelType = ChannelType.public;
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
                .addMembers(channelId: state.id, members: _participants);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

        return GestureDetector(
          onTap: () => _closeKeyboards(context),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              SheetTitleBar(
                title: 'New Channel',
                leadingTitle: 'Close',
                leadingAction: () {
                  context.read<SheetBloc>().add(CloseSheet());
                  _closeKeyboards(context);
                },
                trailingTitle: 'Create',
                trailingAction: createIsBlocked || !_canGoNext
                    ? null
                    : () => context.read<AddChannelBloc>().add(Create()),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(14.0),
                color: Colors.white,
                child: Row(
                  children: [
                    SelectableAvatar(
                      size: 56.0,
                      backgroundColor: Color(0xfff2f1fa),
                      icon: _icon,
                      onTap: () => _toggleEmojiBoard(),
                    ),
                    Expanded(
                      child: SheetTextField(
                        hint: 'Channel name',
                        controller: _channelNameController,
                        focusNode: _channelNameFocusNode,
                        maxLength: 30,
                      ),
                    ),
                  ],
                ),
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
                onPrivateTap: () =>
                    _batchUpdateState(type: ChannelType.private),
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
              _emojiVisible ? _buildEmojiBoard() : Container(),
            ],
          ),
        );
      }),
    );
  }

  void _closeKeyboards(BuildContext context, {bool both = true}) {
    if (both) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _emojiVisible = false;
    });
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 21, 14, 8),
      child: ButtonField(
        title: 'Added participants',
        trailingTitle: count > 0 ? '$count' : 'Add',
        hasArrow: count > 0,
        onTap: () => context
            .read<AddChannelBloc>()
            .add(SetFlowStage(FlowStage.participants)),
      ),
    );
  }
}
