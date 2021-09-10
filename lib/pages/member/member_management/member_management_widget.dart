import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_cubit.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/common/image_widget.dart';
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
      Get.find<MemberManagementCubit>()
          .getMembersFromIds(channel: _currentChannel!);
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
                          child: Text(
                              'CHANNEL MEMBERS (${memberManagementState.allMembers.length})',
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
                    hintText: AppLocalizations.of(context)!.searchMembers,
                    backgroundColor: Color(0xfff9f8f9),
                  ),
                ),
                BlocBuilder<MemberManagementCubit, MemberManagementState>(
                    bloc: Get.find<MemberManagementCubit>(),
                    builder: (ctx, memberManagementState) {
                      if (memberManagementState is MemberManagementInProgress) {
                        return TwakeCircularProgressIndicator();
                      }
                      final members =
                          memberManagementState is MemberManagementSearchState
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
                                            Get.find<MemberManagementCubit>()
                                                .state
                                                .allMembers;
                                        final selectedMembersResult = await push(
                                            RoutePaths.addChannelMembers.path,
                                            arguments:
                                                currentSelectedMembers.isEmpty
                                                    ? null
                                                    : currentSelectedMembers);
                                        if (selectedMembersResult != null &&
                                            selectedMembersResult
                                                is List<Account> &&
                                            selectedMembersResult.isNotEmpty) {
                                          Get.find<MemberManagementCubit>()
                                              .newMembersAdded(
                                                  selectedMembersResult);
                                        }
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
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
                                      padding:
                                          const EdgeInsets.only(left: 46.0),
                                      child: Divider(
                                        color: Color(0x1e000000),
                                        height: 1,
                                      ),
                                    ),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      separatorBuilder: (_, __) => Padding(
                                        padding:
                                            const EdgeInsets.only(left: 46.0),
                                        child: Divider(
                                          color: Color(0x1e000000),
                                          height: 1,
                                        ),
                                      ),
                                      itemCount: members.length,
                                      itemBuilder: (ctx, index) {
                                        final member = members[index];
                                        return _MemberManagementTile(
                                          userId: member.id,
                                          name: member.fullName,
                                          logo: member.picture,
                                          currentChannel: _currentChannel,
                                        );
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
  final Channel? currentChannel;
  final String userId;

  const _MemberManagementTile({
    Key? key,
    required this.name,
    required this.currentChannel,
    required this.userId,
    this.logo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 50,
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ImageWidget(
                  imageType: ImageType.common,
                  imageUrl: logo ?? '',
                  name: name,
                  size: 34,
                )),
            Expanded(
              child: Text(name,
                  style: TextStyle(
                    color: Color(0xff000000),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  )),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, top: 5, bottom: 5, right: 20),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    return modalSheet(
                        context: context,
                        name: name,
                        logo: logo,
                        currentChannel: currentChannel,
                        userId: userId);
                  },
                );
              },
            ),
          ],
        ),
      ),
      onLongPress: () async {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return modalSheet(
                context: context,
                name: name,
                logo: logo,
                currentChannel: currentChannel,
                userId: userId);
          },
        );
      },
    );
  }
}

Widget modalSheet(
    {required BuildContext context,
    required String name,
    required String? logo,
    required Channel? currentChannel,
    required String userId}) {
  return Column(
    children: [
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Container(
          height: 325,
          width: Dim.widthPercent(94),
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: ImageWidget(
                    imageType: ImageType.common,
                    imageUrl: logo,
                    name: name,
                    size: 70,
                  ),
                ),
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          CupertinoIcons.text_bubble_fill,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Send a direct message",
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          CupertinoIcons.shield_lefthalf_fill,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Dismiss as admin",
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35, bottom: 15),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (currentChannel != null) {
                        await Get.find<ChannelsCubit>().removeMembers(
                            channel: currentChannel, userId: userId);
                        Get.find<MemberManagementCubit>()
                            .getMembersFromIds(channel: currentChannel);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: EdgeInsets.fromLTRB(
                              15.0,
                              5.0,
                              15.0,
                              65.0,
                              //  Dim.heightPercent(8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                            content: Text('Member is removed'),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            CupertinoIcons.minus_circle_fill,
                            color: Color(0xFFFF3347),
                          ),
                        ),
                        Text(
                          "Remove from channel",
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFF3347),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 25),
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: Container(
              child: Center(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF004DFF),
                  ),
                ),
              ),
              height: 60,
              width: Dim.widthPercent(94),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    ],
  );
}
