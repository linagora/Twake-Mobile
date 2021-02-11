import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_cubit.dart';
import 'package:twake/blocs/edit_channel_cubit/edit_channel_state.dart';
import 'package:twake/blocs/member_cubit/member_cubit.dart';
import 'package:twake/blocs/member_cubit/member_state.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/member.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:twake/widgets/sheets/button_field.dart';
import 'package:twake/widgets/sheets/draggable_scrollable.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';

class EditChannel extends StatefulWidget {
  final Channel channel;
  final List<Member> members;

  const EditChannel({Key key, this.channel, this.members}) : super(key: key);

  @override
  _EditChannelState createState() => _EditChannelState();
}

class _EditChannelState extends State<EditChannel> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  final PanelController _panelController = PanelController();

  var _members = <Member>[];
  var _showHistoryForNew = true;
  var _canSave = false;

  Channel _channel;
  String _channelId;

  @override
  void initState() {
    super.initState();

    if (widget.channel != null) {
      _channel = widget.channel;
      _channelId = widget.channel.id;
      _nameController.text = _channel.name;
      _descriptionController.text = _channel.description;
    }

    if (widget.members != null) {
      _members = widget.members;
    }

    _nameController.addListener(() {
      final channelName = _nameController.text;
      _batchUpdateState(name: channelName);
      if (channelName.isNotReallyEmpty && !_canSave) {
        setState(() {
          _canSave = true;
        });
      } else if (channelName.isReallyEmpty && _canSave) {
        setState(() {
          _canSave = false;
        });
      }
    });

    _descriptionController.addListener(() {
      _batchUpdateState(description: _descriptionController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EditChannel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel) {
      setState(() {
        _channel = widget.channel;
        _channelId = widget.channel.id;
      });
    }
    if (oldWidget.members != widget.members) {
      setState(() {
        _members = widget.members;
      });
    }
  }

  void _batchUpdateState({
    String channelId,
    String name,
    String description,
    bool showHistoryForNew,
  }) {
    context.read<EditChannelCubit>().update(
          channelId: channelId ?? _channelId,
          name: name ?? _nameController.text,
          description: description ?? _descriptionController.text,
          automaticallyAddNew: showHistoryForNew ?? _showHistoryForNew,
        );
  }

  void _save() {
    context.read<EditChannelCubit>().save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffefeef3),
      resizeToAvoidBottomInset: true,
      body: SlidingUpPanel(
        controller: _panelController,
        onPanelOpened: () => context.read<SheetBloc>().add(SetOpened()),
        onPanelClosed: () => context.read<SheetBloc>().add(SetClosed()),
        onPanelSlide: _onPanelSlide,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        backdropEnabled: true,
        renderPanelSheet: false,
        panel: BlocConsumer<SheetBloc, SheetState>(
          listenWhen: (_, current) =>
              current is SheetShouldOpen || current is SheetShouldClose,
          listener: (context, state) {
            // print('Strange state: $state');
            if (state is SheetShouldOpen) {
              if (_panelController.isPanelClosed) {
                _panelController.open();
              }
            } else if (state is SheetShouldClose) {
              if (_panelController.isPanelOpen) {
                _panelController.close();
              }
            }
          },
          buildWhen: (_, current) => current is FlowUpdated,
          builder: (context, state) {
            var sheetFlow = SheetFlow.editChannel;
            if (state is FlowUpdated) {
              sheetFlow = state.flow;
              return DraggableScrollable(flow: sheetFlow);
            } else {
              return SizedBox();
            }
          },
        ),
        body: SafeArea(
          child: BlocBuilder<EditChannelCubit, EditChannelState>(
              buildWhen: (_, current) => current is EditChannelSaved,
              builder: (context, state) {
                if (state is EditChannelSaved) {
                  context
                      .read<ChannelsBloc>()
                      .add(ReloadChannels(forceFromApi: true));
                  Navigator.of(context).pop();
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 17.0, 16.0, 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xff3840f7),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              SelectableAvatar(size: 74.0),
                              SizedBox(height: 4.0),
                              Text('Change avatar',
                                  style: TextStyle(
                                    color: Color(0xff3840f7),
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                  )),
                            ],
                          ),
                          GestureDetector(
                            onTap: _canSave ? () => _save() : null,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: _canSave != null
                                    ? Color(0xff3840f7)
                                    : Color(0xffa2a2a2),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundedBoxButton(
                          cover:
                              Image.asset('assets/images/add_new_member.png'),
                          title: 'add',
                          onTap: () => _panelController.open(),
                        ),
                        SizedBox(width: 10.0),
                        RoundedBoxButton(
                          cover: Image.asset('assets/images/leave.png'),
                          title: 'leave',
                          onTap: () => print('leave'),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0),
                    HintLine(text: 'CHANNEL INFORMATION', isLarge: true),
                    SizedBox(height: 12.0),
                    Divider(
                      thickness: 0.5,
                      height: 0.5,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    SheetTextField(
                      hint: 'Channel name',
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                    ),
                    Divider(
                      thickness: 0.5,
                      height: 0.5,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    SheetTextField(
                      hint: 'Description',
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                    ),
                    Divider(
                      thickness: 0.5,
                      height: 0.5,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    // ButtonField(
                    //   title: 'Channel type',
                    //   trailingTitle: 'Public',
                    //   hasArrow: true,
                    // ),
                    SizedBox(height: 32.0),
                    HintLine(text: 'MEMBERS', isLarge: true),
                    SizedBox(height: 12.0),
                    Divider(
                      thickness: 0.5,
                      height: 0.5,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    ButtonField(
                      title: 'Member management',
                      trailingTitle: 'Manage',
                      hasArrow: true,
                      onTap: () => _panelController.open(),
                    ),
                    Divider(
                      thickness: 0.5,
                      height: 0.5,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    // SwitchField(
                    //   title: 'Chat history for new members',
                    //   value: _showHistoryForNew,
                    //   onChanged: (value) =>
                    //       _batchUpdateState(showHistoryForNew: value),
                    //   isExtended: true,
                    // ),
                    // SizedBox(height: 8.0),
                    // HintLine(text: 'Show previous chat history for newly added members'),
                  ],
                );
              }),
        ),
      ),
    );
  }

  _onPanelSlide(double position) {
    if (position < 0.4 && _panelController.isPanelAnimating) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}

class RoundedBoxButton extends StatelessWidget {
  final Widget cover;
  final String title;
  final Function onTap;

  const RoundedBoxButton({
    Key key,
    @required this.cover,
    @required this.title,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.0, 13.0, 18.0, 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SizedBox(
          width: 45.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              cover,
              SizedBox(height: 5.0),
              AutoSizeText(
                title,
                minFontSize: 10.0,
                maxFontSize: 13.0,
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xff3840f7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
