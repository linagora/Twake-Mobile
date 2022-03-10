import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_cubit.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_state.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/pages/member/found_member_tile.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/enable_button_widget.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

import 'selected_member_tile.dart';

enum AddAndEditMemberType { createChannel, addNewMember, createDirect }

class AddAndEditMemberWidget extends StatefulWidget {
  final AddAndEditMemberType addAndEditMemberType;

  const AddAndEditMemberWidget({
    Key? key,
    this.addAndEditMemberType = AddAndEditMemberType.createChannel,
  }) : super(key: key);

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

  void routeNewChannel(List<Account> accounts) {
    Navigator.pop(context);
    push(RoutePaths.newChannel.path, arguments: accounts);
  }

  void closeDialog() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // dismiss keyboard when tap outside
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          onPressed: () => popBack(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Theme.of(context).colorScheme.surface,
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
                                  } else if (widget.addAndEditMemberType ==
                                      AddAndEditMemberType.createDirect) {
                                    final selectedMembers =
                                        addMemberState.selectedMembers;

                                    Get.find<NewDirectCubit>()
                                        .newDirect(selectedMembers);
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
                                text: widget.addAndEditMemberType ==
                                        AddAndEditMemberType.createDirect
                                    ? AppLocalizations.of(context)!.create
                                    : AppLocalizations.of(context)!.add,
                                isEnable: addMemberState
                                        .selectedMembers.isNotEmpty &&
                                    !(addMemberState is AddMemberInProgress));
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                            alignment: Alignment.center,
                            width: 170,
                            child: AutoSizeText(
                              AppLocalizations.of(context)!.addMembers,
                              maxFontSize: 17,
                              minFontSize: 12,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17),
                            ),
                          ))
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16,
                  ),
                  child: TwakeSearchTextField(
                    controller: _searchController,
                    hintText: AppLocalizations.of(context)!.searchMembers,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
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
                            AppLocalizations.of(context)!.foundPeople,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                          ),
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
                                : addMemberState.frequentlyContacted.isEmpty
                                    ? addMemberState.allMembers
                                    : addMemberState.frequentlyContacted;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  separatorBuilder: (_, index) => Padding(
                                        padding:
                                            const EdgeInsets.only(left: 46),
                                        child: Divider(
                                          height: 1,
                                       
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary.withOpacity(0.3),
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
                                          if (addMemberState
                                                      .selectedMembers.length >
                                                  9 &&
                                              widget.addAndEditMemberType ==
                                                  AddAndEditMemberType
                                                      .createDirect) {
                                            Utilities.showLimitDialog(
                                              context: context,
                                              titleText:
                                                  AppLocalizations.of(context)!
                                                      .groupChatLimit,
                                              buttonText1:
                                                  AppLocalizations.of(context)!
                                                      .createPrivateChannel,
                                              buttonText2:
                                                  AppLocalizations.of(context)!
                                                      .continueLimit,
                                              onButtonClick1: () =>
                                                  routeNewChannel(addMemberState
                                                      .selectedMembers),
                                              onButtonClick2: closeDialog,
                                              message:
                                                  AppLocalizations.of(context)!
                                                      .groupDirectLimit,
                                              duration: Duration(hours: 1),
                                            );
                                          } else {
                                            Get.find<AddMemberCubit>()
                                                .selectMember(user);
                                            _searchController.text = '';
                                          }
                                        }
                                      },
                                      isSelected: isSelected,
                                      imageUrl: user.picture ?? '',
                                      name: '${user.fullName}',
                                      userId: user.id,
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
