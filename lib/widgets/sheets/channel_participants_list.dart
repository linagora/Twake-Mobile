import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/profile_bloc.dart';
import 'package:twake/models/user.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/radio_item.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel_bloc.dart';
import 'package:twake/blocs/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelParticipantsList extends StatefulWidget {
  @override
  _ChannelParticipantsListState createState() =>
      _ChannelParticipantsListState();
}

class _ChannelParticipantsListState extends State<ChannelParticipantsList> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UserBloc>().add(LoadUsers('')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _return() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddChannelBloc>().add(SetFlowStage(FlowStage.type));
  }

  @override
  Widget build(BuildContext context) {
    var participants = [
      'Jean Paul Loreain',
      'Ralph Lauren',
      'Pierre Sortireux',
      'Walles Chemberlin',
    ];

    var selectedIndex = 0;

    return Column(
      children: [
        SheetTitleBar(
          title: 'Add participants',
          leadingTitle: 'Back',
          leadingAction: () => _return(),
          trailingTitle: 'Add',
          trailingAction: () => _return(),
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
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return RadioItem(
                title: users[index].name,
                selected: selectedIndex == index,
                onTap: () => selectedIndex = index,
              );
            },
          );
        }),
      ],
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
