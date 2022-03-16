import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_cubit.dart';
import 'package:twake/blocs/channels_cubit/member_management_cubit/member_management_state.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/common/button_text_builder.dart';
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
            child: Column(
              children: [
                Container(
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
                            )),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                              AppLocalizations.of(context)!.memberManagement,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17)))
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondaryContainer,
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
                            AppLocalizations.of(context)!.channelMembersPlural(
                                memberManagementState.allMembers.length),
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  child: TwakeSearchTextField(
                    controller: _searchController,
                    hintText: AppLocalizations.of(context)!.searchMembers,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .addMember,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 46.0),
                                      child: Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.3),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.3),
                                          height: 1,
                                        ),
                                      ),
                                      itemCount: members.length,
                                      itemBuilder: (ctx, index) {
                                        final member = members[index];
                                        return _MemberManagementTile(
                                          user: member,
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
  final Channel? currentChannel;
  final Account user;

  const _MemberManagementTile({
    Key? key,
    required this.currentChannel,
    required this.user,
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
                imageUrl: user.picture ?? '',
                name: user.fullName,
                size: 34,
              ),
            ),
            Expanded(
              child: Text(user.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w400)),
            ),
            user.id == Globals.instance.userId
                ? Text(
                    AppLocalizations.of(context)!.youRespectful,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                  )
                : SizedBox.shrink(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, top: 5, bottom: 5, right: 20),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).colorScheme.secondary,
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
                        currentChannel: currentChannel,
                        user: user);
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
                context: context, currentChannel: currentChannel, user: user);
          },
        );
      },
    );
  }
}

Widget modalSheet(
    {required BuildContext context,
    required Channel? currentChannel,
    required Account user}) {
  final memberManagementCubit = Get.find<MemberManagementCubit>().state;
  final bool canLeave = currentChannel == null
      ? false
      : (currentChannel.isPrivate &&
              user.id == Globals.instance.userId &&
              memberManagementCubit.allMembers.length == 1)
          ? false
          : true;
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
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Container(
          width: Dim.widthPercent(94),
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: ImageWidget(
                    imageType: ImageType.common,
                    imageUrl: user.picture,
                    name: user.fullName,
                    size: 70,
                  ),
                ),
                Text(user.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 17.0, fontWeight: FontWeight.w700)),
                Padding(
                  padding: const EdgeInsets.only(top: 35, bottom: 15),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.find<NewDirectCubit>().newDirect([user]);
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            CupertinoIcons.text_bubble_fill,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.sendDirect,
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
                canLeave
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (currentChannel != null) {
                              user.id == Globals.instance.userId
                                  ? leaveChannel(currentChannel, user, context)
                                  : removeMember(currentChannel, user, context);
                            }
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  CupertinoIcons.minus_circle_fill,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              Text(
                                  user.id == Globals.instance.userId
                                      ? AppLocalizations.of(context)!
                                          .leaveChannel("")
                                      : AppLocalizations.of(context)!
                                          .removeFromChannel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17)),
                            ],
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
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
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: Container(
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.surface,
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

leaveChannel(Channel currentChannel, Account user, BuildContext context) async {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: Get.theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      title: Text(
        AppLocalizations.of(context)!.leaveChannel(currentChannel.name),
        style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 16),
      ),
      content: Text(
        AppLocalizations.of(context)!.leaveChannelWarning,
        style: Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
      ),
      actions: <Widget>[
        SizedBox(
          height: 45,
          width: 80,
          child: ButtonTextBuilder(
            Key('cancel'),
            onButtonClick: () => Navigator.pop(context),
            backgroundColor: Get.isDarkMode
                ? Get.theme.backgroundColor
                : Get.theme.colorScheme.secondary,
          )
              .setWidth(double.infinity)
              .setHeight(50)
              .setText(AppLocalizations.of(context)!.cancel)
              .setTextStyle(Get.isDarkMode
                  ? Get.theme.textTheme.headline1!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w600)
                  : Get.theme.textTheme.bodyText1!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w500))
              .build(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 45,
            width: 80,
            child: ButtonTextBuilder(
              Key('OK'),
              onButtonClick: () async {
                await Get.find<ChannelsCubit>()
                    .removeMembers(channel: currentChannel, userId: user.id);
              },
              backgroundColor: Get.theme.colorScheme.surface,
            )
                .setWidth(double.infinity)
                .setHeight(50)
                .setText(AppLocalizations.of(context)!.ok)
                .setTextStyle(Get.isDarkMode
                    ? Get.theme.textTheme.headline1!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w600)
                    : Get.theme.textTheme.bodyText1!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w500))
                .build(),
          ),
        ),
      ],
    ),
  );
}

removeMember(Channel currentChannel, Account user, BuildContext context) async {
  await Get.find<ChannelsCubit>()
      .removeMembers(channel: currentChannel, userId: user.id);
  Get.find<MemberManagementCubit>().getMembersFromIds(channel: currentChannel);
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: EdgeInsets.fromLTRB(
        15.0,
        5.0,
        15.0,
        65.0,
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
      content: Text(
        AppLocalizations.of(context)!.memberRemoved,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(fontSize: 17.0, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
