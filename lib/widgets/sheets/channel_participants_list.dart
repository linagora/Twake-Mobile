import 'dart:async';

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
import 'package:twake/blocs/user_bloc/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelParticipantsList extends StatefulWidget {
  final bool isDirect;

  const ChannelParticipantsList({
    Key key,
    this.isDirect = false,
  }) : super(key: key);

  @override
  _ChannelParticipantsListState createState() =>
      _ChannelParticipantsListState();
}

class _ChannelParticipantsListState extends State<ChannelParticipantsList> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer _debounce;
  String _searchRequest;
  bool _isDirect;

  @override
  void initState() {
    super.initState();

    _isDirect = widget.isDirect;

    _controller.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_searchRequest != _controller.text) {
          _searchRequest = _controller.text;
          if (_searchRequest.length > 1) {
            context.read<UserBloc>().add(LoadUsers(_searchRequest));
          } else if (_searchRequest.isEmpty) {
            context.read<UserBloc>().add(LoadUsers(''));
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChannelParticipantsList oldWidget) {
    if (oldWidget.isDirect != widget.isDirect) {
      _isDirect = widget.isDirect;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _close() {
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
      ..add(Update(
        name: '',
        type: ChannelType.direct,
        participants: participantsIds,
      ))
      ..add(Create());
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddChannelBloc, AddChannelState>(
      listener: (context, state) {
        if (state is Created) {
          // Reload channels
          context.read<ChannelsBloc>().add(ReloadChannels(forceFromApi: true));
          // Reload directs
          context.read<DirectsBloc>().add(ReloadChannels(forceFromApi: true));
          // Close sheet
          context.read<SheetBloc>().add(CloseSheet());
          // Reset selected participants
          context.read<AddChannelBloc>().add(Update(participants: []));
          _controller.clear();
          // Redirect user to created direct
          if (_isDirect) {
            String channelId = state.id;
            openDirect(context, channelId);
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
      },
      buildWhen: (_, current) {
        return (current is Updated || current is Creation);
      },
      builder: (context, state) {
        return Column(
          children: [
            SheetTitleBar(
              title: _isDirect ? 'New direct chat' : 'Add participants',
              leadingTitle: _isDirect ? 'Close' : 'Back',
              leadingAction: _isDirect ? () => _close() : () => _return(),
              trailingTitle: _isDirect ? null : 'Add',
              trailingAction: _isDirect ? null : () => _return(),
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
                users = state.users;
                // print('-------------------------------');
                // for (var u in users) {
                //   print('${u.id} - ${u.username}');
                // }
                // print('-------------------------------');
              }
              return BlocBuilder<AddChannelBloc, AddChannelState>(
                buildWhen: (previous, current) => current is Updated,
                builder: (context, state) {
                  var selectedIds = <String>[];
                  var name = '';
                  var description = '';
                  if (state is Updated) {
                    name = state.repository?.name;
                    description = state.repository?.description;
                    selectedIds = state.repository?.members;
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return SearchItem(
                        title: user.firstName.isNotEmpty ||
                                user.lastName.isNotEmpty
                            ? '${user.firstName} ${user.lastName}'
                            : '${user.username}',
                        selected: selectedIds.contains(user.id),
                        allowMultipleChoice: !_isDirect,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_isDirect) {
                            selectedIds = [user.id];
                            _createDirect(selectedIds);
                          } else {
                            if (selectedIds.contains(user.id)) {
                              setState(() {
                                selectedIds.remove(user.id);
                              });
                            } else {
                              setState(() {
                                selectedIds.add(user.id);
                              });
                            }
                            context.read<AddChannelBloc>().add(Update(
                                  name: name,
                                  description: description,
                                  participants: selectedIds,
                                ));
                          }
                        },
                      );
                    },
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class SearchTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(primaryColor: Colors.black.withOpacity(0.36)),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(CupertinoIcons.search),
          hintText: hint,
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
