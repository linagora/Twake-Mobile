import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/models/user.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/widgets/sheets/search_item.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_bloc.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_state.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_event.dart';
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParticipantsList extends StatefulWidget {
  final bool isDirect;
  final bool isModal;
  final String title;

  const ParticipantsList({
    Key key,
    this.isDirect = false,
    this.isModal,
    @required this.title,
  }) : super(key: key);

  @override
  _ParticipantsListState createState() => _ParticipantsListState();
}

class _ParticipantsListState extends State<ParticipantsList> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer _debounce;
  String _searchRequest;
  bool _isDirect;
  bool _isModal;
  bool _shouldFocus = true;
  String _title;

  var _selectedIds = <String>[];
  var _selectedUsers = <User>[];

  @override
  void initState() {
    super.initState();

    _isDirect = widget.isDirect;
    _title = widget.title;
    _isModal = widget.isModal;
    if (widget.isModal == null) {
      _isModal = _isDirect;
    }

    _controller.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_searchRequest != _controller.text) {
          _searchRequest = _controller.text;
          context.read<UserBloc>().add(LoadUsers(_searchRequest));
          // if (_searchRequest.length > 1) {
          //   context.read<UserBloc>().add(LoadUsers(_searchRequest));
          // } else if (_searchRequest.isEmpty) {
          //   context.read<UserBloc>().add(LoadUsers(''));
          // }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ParticipantsList oldWidget) {
    if (oldWidget.isDirect != widget.isDirect) {
      _isDirect = widget.isDirect;
    }
    if (oldWidget.title != widget.title) {
      _title = widget.title;
    }
    if (oldWidget.isModal != widget.isModal) {
      _isModal = widget.isModal;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _close() {
    setState(() {
      _shouldFocus = true; // reset value
    });
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<SheetBloc>().add(CloseSheet());
  }

  void _return() {
    FocusScope.of(context).requestFocus(new FocusNode());
    // context.read<SheetBloc>().add(ClearSheet());
    context.read<AddChannelBloc>().add(SetFlowStage(FlowStage.info));
  }

  void _createDirect(List<String> participantsIds) {
    context.read<AddChannelBloc>()
      ..add(UpdateDirect(
        member: participantsIds.first,
      ))
      ..add(CreateDirect());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SheetBloc, SheetState>(
      listener: (context, state) {
        if (state is SheetOpened && _isDirect && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      },
      child: BlocConsumer<AddChannelBloc, AddChannelState>(
        listener: (context, state) {
          if (state is Created || state is DirectCreated) {
            // Reload channels
            context
                .read<ChannelsBloc>()
                .add(ReloadChannels(forceFromApi: true));
            // Reload directs
            context.read<DirectsBloc>().add(ReloadChannels(forceFromApi: true));
            // Close sheet
            context.read<SheetBloc>().add(CloseSheet());
            // Reset selected participants
            context.read<AddChannelBloc>().add(Update(participants: []));
            setState(() {
              _selectedIds.clear();
              _selectedUsers.clear();
            });
            _controller.clear();
            // Redirect user to created direct
            if (state is DirectCreated) {
              String channelId = state.id;
              openDirect(context, channelId);
            }
          } else if (state is Error) {
            // Show an error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is StageUpdated && state.stage == FlowStage.participants) {
            if (_searchRequest.isEmpty) {
              context.read<UserBloc>().add(LoadUsers(_searchRequest));
            }
          }
        },
        buildWhen: (_, current) {
          return (current is Updated ||
              current is DirectUpdated ||
              current is Creation ||
              current is StageUpdated);
        },
        builder: (context, state) {
          if (state is StageUpdated) {
            // print('STAGE REBUILD: ${state.stage}');
            if (state.stage == FlowStage.participants &&
                !_isDirect &&
                _shouldFocus) {
              if (_focusNode.canRequestFocus) _focusNode.requestFocus();
              _shouldFocus = false;
            }
          }
          return Column(
            children: [
              SheetTitleBar(
                title: _title,
                leadingTitle: _isModal ? 'Close' : 'Back',
                leadingAction: _isModal ? () => _close() : () => _return(),
                trailingTitle: _isDirect
                    ? null
                    : _isModal
                        ? 'Add'
                        : 'Save',
                trailingAction: _isDirect
                    ? null
                    : (_isModal ? () => _close() : () => _return()),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 7),
                child: SearchTextField(
                  hint: 'Search members',
                  controller: _controller,
                  focusNode: _focusNode,
                ),
              ),
              BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                var users = <User>[];

                if (state is MultipleUsersLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MultipleUsersLoaded) {
                  if (_isDirect) {
                    users = state.users;
                  } else {
                    if (_selectedUsers.isEmpty) {
                      _selectedIds.clear();
                    }
                    users = state.users..addAll(_selectedUsers);
                    //remove duplicated user and sort the list
                    users = users.toSet().toList();
                    users.sort((a, b) => a.username.compareTo(b.username));
                  }
                  // print('-------------------------------');
                  // for (var u in users) {
                  //   print('${u.id} - ${u.username}');
                  // }
                  // print('-------------------------------');
                }
                return BlocBuilder<AddChannelBloc, AddChannelState>(
                  buildWhen: (previous, current) => current is Updated || current is Creation,
                  builder: (context, state) {
                    var name = '';
                    var description = '';
                    if (state is Updated) {
                      name = state.repository?.name;
                      description = state.repository?.description;
                      _selectedIds = state.repository?.members;
                      if (!_isDirect) {
                        print('UsERS: ${users.map((e) => e.username)}');
                        print('UsERS IDS: ${users.map((e) => e.id)}');
                        print('selected ids: $_selectedIds');
                      }
                    }
                    print(
                        'Selected UsERS: ${_selectedUsers.map((e) => e.username)}');
                    // print('Selected Ids: $selectedIds}');

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          User user = users[index];
                          return SearchItem(
                            title: user.firstName.isNotEmpty ||
                                    user.lastName.isNotEmpty
                                ? '${user.firstName} ${user.lastName}'
                                : '${user.username}',
                            selected: _selectedIds.contains(user.id),
                            allowMultipleChoice: !_isDirect,
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (_isDirect && !(state is Creation)) {
                                _selectedIds = [user.id];
                                _createDirect(_selectedIds);
                              } else {
                                if (_selectedIds.contains(user.id)) {
                                  _selectedIds.remove(user.id);
                                  _selectedUsers.removeWhere((selected) => selected.id == user.id);
                                } else {
                                  _selectedIds.add(user.id);
                                  _selectedUsers.add(user);
                                }
                                context.read<AddChannelBloc>().add(
                                      Update(
                                        name: name,
                                        description: description,
                                        participants: _selectedIds,
                                      ),
                                    );
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class SearchTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;

  const SearchTextField({
    Key key,
    @required this.hint,
    @required this.controller,
    @required this.focusNode,
  }) : super(key: key);

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(primaryColor: Colors.black.withOpacity(0.36)),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(CupertinoIcons.search),
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.4),
            fontSize: 17.0,
            fontWeight: FontWeight.w400,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff767680).withOpacity(0.12),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff767680).withOpacity(0.12),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          fillColor: Color(0xff767680).withOpacity(0.12),
          filled: true,
        ),
      ),
    );
  }
}
