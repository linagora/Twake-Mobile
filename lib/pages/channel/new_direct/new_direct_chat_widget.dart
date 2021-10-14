import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_cubit.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_state.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/pages/member/add_and_edit_member_widget.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/twake_circular_progress_indicator.dart';

class NewDirectChatWidget extends StatefulWidget {
  const NewDirectChatWidget({Key? key}) : super(key: key);

  @override
  _NewDirectChatWidgetState createState() => _NewDirectChatWidgetState();
}

class _NewDirectChatWidgetState extends State<NewDirectChatWidget> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool isVisible = true;
  bool showClearButton = false;

  UniqueKey key = UniqueKey();
  @override
  void initState() {
    super.initState();
    Get.find<NewDirectCubit>().fetchAllMember();
    _searchFocusNode.addListener(_onFocusChange);
    _searchController.addListener(() {
      Get.find<NewDirectCubit>().searchMembers(_searchController.text);
      setState(() {
        showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  void _onFocusChange() {
    setState(() {
      isVisible = !isVisible;
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
              if (isVisible)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => popBack(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF004DFF),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                  ],
                ),
              if (isVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Container(
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
                              child: Text(
                                AppLocalizations.of(context)!.createNewChannel,
                                style: TextStyle(
                                  color: Color(0xff000000),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
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
                ),
              if (isVisible)
                Padding(
                  padding: EdgeInsets.only(
                    left: Dim.widthPercent(15),
                  ),
                  child: Divider(
                    thickness: 0.5,
                  ),
                ),
              if (isVisible)
                Container(
                  height: 40,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      push(RoutePaths.addAndEditDirectMembers.path,
                          arguments: AddAndEditMemberType.createDirect);
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Image.asset(imageGroup),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.newChat,
                              style: TextStyle(
                                color: Color(0xff000000),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
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
              if (isVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.directChats,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              Padding(
                key: key,
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          controller: _searchController,
                          cursorColor: Color(0xff004dff),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                          decoration: new InputDecoration(
                            contentPadding:
                                EdgeInsets.only(top: 10, bottom: 10, left: 0),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: showClearButton
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right: 16.0, left: 16),
                                    child: GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            color: Colors.grey,
                                            width: 16,
                                            height: 16,
                                            child: Icon(
                                              Icons.close,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                  )
                                : SizedBox.shrink(),
                            suffixIconConstraints:
                                BoxConstraints(minHeight: 16, minWidth: 16),
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            filled: true,
                            hintStyle: TextStyle(
                              color: Color(0xff8e8e93),
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                            hintText:
                                AppLocalizations.of(context)!.searchForMembers,
                            fillColor: Color(0xfff9f8f9),
                          ),
                        ),
                      ),
                      if (!isVisible)
                        GestureDetector(
                          onTap: () => popBack(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF004DFF),
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                            Get.find<NewDirectCubit>().newDirect([member]);
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
            Container(
              constraints: BoxConstraints(maxWidth: Dim.widthPercent(70)),
              child: Text(name,
                  style: TextStyle(
                    color: Color(0xff000000),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
