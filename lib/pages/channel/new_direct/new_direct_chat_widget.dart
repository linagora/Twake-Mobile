import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_cubit.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class NewDirectChatWidget extends StatefulWidget {
  const NewDirectChatWidget({Key? key}) : super(key: key);

  @override
  _NewDirectChatWidgetState createState() => _NewDirectChatWidgetState();
}

class _NewDirectChatWidgetState extends State<NewDirectChatWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<NewDirectCubit>().fetchAllMember();

    _searchController.addListener(() {
      Get.find<NewDirectCubit>().searchMembers(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("New direct chat",
                          style: TextStyle(
                            fontFamily: 'SFProText',
                            color: Color(0xff000000),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            letterSpacing: -0.41,
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => popBack(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Image.asset(imagePathCancel),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                child: Container(
                  height: 44,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: TwakeSearchTextField(
                        controller: _searchController,
                        height: 44,
                        hintText: '',
                        showPrefixIcon: false,
                      )),
                      Positioned(
                          left: 8,
                          top: 12,
                          child: Text("To:",
                              style: TextStyle(
                                color: Color(0x66000000),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              )))
                    ],
                  ),
                ),
              ),
              Container(
                height: 40,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => push(RoutePaths.newChannel.path),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Image.asset(imageGroup),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Create a New Channel',
                              style: TextStyle(
                                color: Color(0xff000000),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Color(0xff004dff),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 23.0, left: 16, bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECENT CHATS',
                    style: TextStyle(
                      color: Color(0x59000000),
                      fontFamily: 'SFProText',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
              BlocBuilder<NewDirectCubit, NewDirectState>(
                  bloc: Get.find<NewDirectCubit>(),
                  builder: (context, newDirectState) {
                    if (newDirectState is NewDirectInProgress) {
                      return Container(
                          height: 36,
                          width: 36,
                          child: TwakeCircularProgressIndicator());
                    }
                    if (newDirectState.recentChats.isEmpty) {
                      return SizedBox.shrink();
                    }
                    final recentChats =
                        newDirectState.recentChats.entries.toList();
                    return Container(
                      height: 80,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: newDirectState.recentChats.length,
                        itemBuilder: (BuildContext context, int index) {
                          final member = recentChats[index];
                          return _RecentChatTile(
                            onRecentChatTileClick: () {
                              popBack();
                              NavigatorService.instance.navigate(
                                channelId: member.key,
                              ); // key is channelId
                            },
                            name: member.value.fullName,
                            imageUrl: member.value.picture ?? '',
                          );
                        },
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('PEOPLE',
                      style: TextStyle(
                        color: Color(0x59000000),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                      )),
                ),
              ),
              Expanded(
                child: BlocBuilder<NewDirectCubit, NewDirectState>(
                  bloc: Get.find<NewDirectCubit>(),
                  builder: (context, newDirectState) {
                    if (newDirectState is NewDirectInProgress) {
                      return Align(
                          alignment: Alignment.center,
                          child: TwakeCircularProgressIndicator());
                    }
                    final members = newDirectState is NewDirectFoundMemberState
                        ? newDirectState.foundMembers
                        : newDirectState.members;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      separatorBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(left: 70, right: 14),
                        child: Divider(
                          height: 1,
                        ),
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return _FoundPeopleDirectTile(
                          onFoundPeopleDirectTileClick: () {
                            Get.find<NewDirectCubit>().newDirect(member);
                          },
                          name: member.fullName,
                          imageUrl: member.picture ?? '',
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

typedef OnRecentChatTileClick = void Function();

class _RecentChatTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final OnRecentChatTileClick? onRecentChatTileClick;

  const _RecentChatTile(
      {Key? key,
      this.onRecentChatTileClick,
      required this.name,
      required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRecentChatTileClick,
      child: Container(
        width: 66,
        height: 78,
        child: Column(
          children: [
            ImageWidget(
              imageType: ImageType.common,
              size: 52,
              imageUrl: imageUrl,
              name: name,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Color(0x59000000),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

typedef OnFoundPeopleDirectTileClick = void Function();

class _FoundPeopleDirectTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final OnFoundPeopleDirectTileClick? onFoundPeopleDirectTileClick;

  const _FoundPeopleDirectTile(
      {Key? key,
      this.onFoundPeopleDirectTileClick,
      required this.name,
      required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFoundPeopleDirectTileClick,
      child: Container(
        height: 60,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 12),
              child: ImageWidget(
                imageType: ImageType.common,
                imageUrl: imageUrl,
                size: 40,
                name: name,
              ),
            ),
            Text(name,
                style: TextStyle(
                  color: Color(0xff000000),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                ))
          ],
        ),
      ),
    );
  }
}
