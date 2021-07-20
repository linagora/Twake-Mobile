import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_cubit.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_state.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/common/rounded_widget.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class MemberManagementWidget extends StatefulWidget {
  const MemberManagementWidget({Key? key}) : super(key: key);

  @override
  _MemberManagementWidgetState createState() => _MemberManagementWidgetState();
}

class _MemberManagementWidgetState extends State<MemberManagementWidget> {
  late final Channel? _currentChannel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentChannel = Get.arguments;
    if (_currentChannel != null) {
      Get.find<MemberManagementCubit>().getMembersFromIds(_currentChannel!.members);
    }

    _searchController.addListener(() {
      Get.find<MemberManagementCubit>().searchMembers(_searchController.text);
    });
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
          bottom: false,
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
                              color: Color(0xff004dff),
                            )),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Member management',
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
                BlocBuilder<MemberManagementCubit, MemberManagementState>(
                    bloc: Get.find<MemberManagementCubit>(),
                    builder: (ctx, memberManagementState) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 16, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('CHANNEL MEMBERS (${memberManagementState.allMembers.length})',
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      );
                    }),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  child: TwakeSearchTextField(
                    controller: _searchController,
                    hintText: 'Search for members',
                    backgroundColor: Color(0xfff9f8f9),
                  ),
                ),


                BlocBuilder<MemberManagementCubit, MemberManagementState>(
                  bloc: Get.find<MemberManagementCubit>(),
                    builder: (ctx, memberManagementState) {
                  if (memberManagementState is MemberManagementInProgress) {
                    return TwakeCircularProgressIndicator();
                  }
                  final members = memberManagementState is MemberManagementSearchState
                              ? memberManagementState.searchResults
                              : memberManagementState.allMembers;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final currentSelectedMembers =
                                        Get.find<MemberManagementCubit>().state.allMembers;
                                    final selectedMembersResult = await push(
                                        RoutePaths.addChannelMembers.path,
                                        arguments: currentSelectedMembers.isEmpty
                                            ? null
                                            : currentSelectedMembers);
                                        if (selectedMembersResult != null &&
                                            selectedMembersResult is List<Account> &&
                                            selectedMembersResult.isNotEmpty) {
                                          Get.find<MemberManagementCubit>()
                                              .newMembersAdded(selectedMembersResult);
                                        }
                                      },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: 50,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: RoundedWidget(
                                            borderRadius: 17,
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              color: Color(0x14969ca4),
                                              child: Icon(
                                                Icons.add,
                                                color: Color(0xff004dff),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text("Add a member",
                                            style: TextStyle(
                                              color: Color(0xff004dff),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 46.0),
                                  child: Divider(
                                    color: Color(0x1e000000),
                                    height: 1,
                                  ),
                                ),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  separatorBuilder: (_, __) => Padding(
                                    padding: const EdgeInsets.only(left: 46.0),
                                    child: Divider(
                                      color: Color(0x1e000000),
                                      height: 1,
                                    ),
                                  ),
                                  itemCount: members.length,
                                  itemBuilder: (ctx, index) {
                                    final member = members[index];
                                    return _MemberManagementTile(name: member.fullName, logo: member.thumbnail,);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberManagementTile extends StatelessWidget {
  final String name;
  final String? logo;

  const _MemberManagementTile({Key? key, required this.name, this.logo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RoundedImage(
              imageUrl: logo,
              width: 34,
              height: 34,
            ),
          ),
          Expanded(
            child: Text(name,
                style: TextStyle(
                  color: Color(0xff000000),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                )),
          )
        ],
      ),
    );
  }
}
