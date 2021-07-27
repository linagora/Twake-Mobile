import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_cubit.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_state.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/pages/member/found_member_tile.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/enable_button_widget.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

import 'selected_member_tile.dart';

enum AddAndEditMemberType { createChannel, addNewMember }

class AddAndEditMemberWidget extends StatefulWidget {
  final AddAndEditMemberType addAndEditMemberType;

  const AddAndEditMemberWidget(
      {Key? key,
      this.addAndEditMemberType = AddAndEditMemberType.createChannel})
      : super(key: key);

  @override
  _AddAndEditMemberWidgetState createState() => _AddAndEditMemberWidgetState();
}

class _AddAndEditMemberWidgetState extends State<AddAndEditMemberWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    Get.find<AddMemberCubit>().fetchAllMembers(
        selectedMembers: (arguments != null && arguments is List<Account>)
            ? arguments
            : null);

    _searchController.addListener(() {
      Get.find<AddMemberCubit>().searchMembers(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f6),
      body: GestureDetector(
        onTap: () {
          // dismiss keyboard when tap outside
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Container(
            color: Color(0xfff2f2f6),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          onPressed: () => popBack(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BlocBuilder<AddMemberCubit, AddMemberState>(
                          bloc: Get.find<AddMemberCubit>(),
                          builder: (ctx, addMemberState) {
                            return EnableButtonWidget(
                                onEnableButtonWidgetClick: () async {
                                  if (widget.addAndEditMemberType ==
                                      AddAndEditMemberType.createChannel) {
                                    popBack(
                                        result: addMemberState.selectedMembers);
                                  } else {
                                    final currentState =
                                        Get.find<ChannelsCubit>().state;
                                    if (currentState is ChannelsLoadedSuccess &&
                                        currentState.selected != null) {
                                      final results =
                                          await Get.find<AddMemberCubit>()
                                              .addMembersToChannel(
                                                  currentState.selected!,
                                                  addMemberState
                                                      .selectedMembers);
                                      popBack(result: results);
                                    }
                                  }
                                },
                                text: 'Add',
                                isEnable: addMemberState
                                        .selectedMembers.isNotEmpty &&
                                    !(addMemberState is AddMemberInProgress));
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Add members",
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ))
                    ],
                  ),
                ),
                Divider(
                  color: Color(0x1e000000),
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16,
                  ),
                  child: TwakeSearchTextField(
                    controller: _searchController,
                    hintText: 'Search for members',
                    backgroundColor: Color(0xfffcfcfc),
                    fontSize: 15,
                  ),
                ),
                BlocBuilder<AddMemberCubit, AddMemberState>(
                    bloc: Get.find<AddMemberCubit>(),
                    buildWhen: (_, current) =>
                        current is AddMemberInSearch ||
                        current is AddMemberInFrequentlyContacted,
                    builder: (context, addMemberState) {
                      if (addMemberState.selectedMembers.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Container(
                        height: 44,
                        child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (_, index) => SizedBox(
                                  width: 8,
                                ),
                            itemCount: addMemberState.selectedMembers.length,
                            itemBuilder: (context, index) {
                              final selectedUser =
                                  addMemberState.selectedMembers[index];
                              return SelectedMemberTile(
                                  onSelectedMemberTileClick: () {
                                    Get.find<AddMemberCubit>()
                                        .removeMember(selectedUser);
                                  },
                                  memberName: '${selectedUser.fullName}');
                            }),
                      );
                    }),
                BlocBuilder<AddMemberCubit, AddMemberState>(
                    bloc: Get.find<AddMemberCubit>(),
                    builder: (ctx, addMemberState) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 14, left: 16, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              addMemberState is AddMemberInSearch
                                  ? 'FOUND PEOPLE'
                                  : 'FREQUENTLY CONTACTED',
                              style: TextStyle(
                                color: Color(0x59000000),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      );
                    }),
                Expanded(
                    child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: BlocBuilder<AddMemberCubit, AddMemberState>(
                      bloc: Get.find<AddMemberCubit>(),
                      builder: (context, addMemberState) {
                        List<Account> users =
                            (addMemberState is AddMemberInSearch)
                                ? addMemberState.searchResults
                                : addMemberState.frequentlyContacted;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                              color: Colors.white,
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  separatorBuilder: (_, index) => Padding(
                                        padding:
                                            const EdgeInsets.only(left: 46),
                                        child: Divider(
                                          height: 1,
                                          color: Color(0x1e000000),
                                        ),
                                      ),
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    final isSelected = addMemberState
                                            .selectedMembers
                                            .indexWhere((element) =>
                                                element.id == user.id) !=
                                        -1;
                                    return FoundMemberTile(
                                      onFoundMemberTileClick: () {
                                        if (isSelected) {
                                          Get.find<AddMemberCubit>()
                                              .removeMember(user);
                                        } else {
                                          Get.find<AddMemberCubit>()
                                              .selectMember(user);
                                          _searchController.text = '';
                                        }
                                      },
                                      isSelected: isSelected,
                                      imageUrl: user.picture ?? '',
                                      name: '${user.fullName}',
                                    );
                                  })),
                        );
                      },
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
