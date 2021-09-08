import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_cubit.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_state.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/pages/member/selected_member_tile.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/common/enable_button_widget.dart';
import 'package:twake/widgets/common/pick_image_widget.dart';
import 'package:twake/pages/channel/selectable_channel_type_widget.dart';
import 'package:twake/routing/app_router.dart';

class NewChannelWidget extends StatefulWidget {
  const NewChannelWidget() : super();

  @override
  _NewChannelWidgetState createState() => _NewChannelWidgetState();
}

class _NewChannelWidgetState extends State<NewChannelWidget> {
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();

  @override
  void dispose() {
    _nameEditingController.dispose();
    _descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f6),
      body: GestureDetector(
        onTap: () {
          // dismiss keyboard when tap outside
          FocusManager.instance.primaryFocus?.unfocus();
          Get.find<AddChannelCubit>().showEmoijKeyBoard(false);
        },
        child: SafeArea(
          child: Container(
            color: Color(0xfff2f2f6),
            child: Column(
              children: [
                BlocListener<AddChannelCubit, AddChannelState>(
                  bloc: Get.find<AddChannelCubit>(),
                  listenWhen: (previousState, currentState) {
                    return currentState is AddChannelSuccess ||
                        currentState is AddChannelFailure;
                  },
                  listener: (context, state) {
                    if (state is AddChannelSuccess) {
                      popToHome();
                    } else if (state is AddChannelFailure) {
                      Get.find<AddChannelCubit>().validateAddChannelData(
                          name: _nameEditingController.text);
                    }
                  },
                  child: SizedBox.shrink(),
                ),
                Container(
                  color: Colors.white,
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          onPressed: () => popBack(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BlocBuilder<AddChannelCubit, AddChannelState>(
                          bloc: Get.find<AddChannelCubit>(),
                          builder: (context, addChannelState) {
                            return EnableButtonWidget(
                                onEnableButtonWidgetClick: () =>
                                    Get.find<AddChannelCubit>().create(
                                        name: _nameEditingController.text,
                                        description:
                                            _descriptionEditingController.text),
                                text: 'Create',
                                isEnable: (addChannelState
                                            is AddChannelValidation &&
                                        addChannelState.validToCreateChannel)
                                    ? true
                                    : false);
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            "New channel",
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
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          height: 80,
                          // color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Container(
                              child: Row(
                                children: [
                                  BlocBuilder<AddChannelCubit, AddChannelState>(
                                      bloc: Get.find<AddChannelCubit>(),
                                      builder: (context, addChannelState) {
                                        if (addChannelState
                                            .emoijIcon.isNotEmpty) {
                                          return _buildSelectedChannelIcon(
                                              addChannelState.emoijIcon);
                                        }
                                        return PickImageWidget(
                                            onPickImageWidgetClick: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          Get.find<AddChannelCubit>()
                                              .showEmoijKeyBoard(true);
                                        });
                                      }),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Flexible(
                                    child: Focus(
                                      onFocusChange: (hasFocus) {
                                        if (hasFocus) {
                                          Get.find<AddChannelCubit>()
                                              .showEmoijKeyBoard(false);
                                        }
                                      },
                                      child: TextFormField(
                                        onFieldSubmitted: (_) => FocusManager
                                            .instance.primaryFocus
                                            ?.nextFocus(),
                                        textInputAction: TextInputAction.next,
                                        onChanged: (text) =>
                                            Get.find<AddChannelCubit>()
                                                .validateAddChannelData(
                                                    name: text),
                                        controller: _nameEditingController,
                                        cursorColor: Colors.black,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(30)
                                        ],
                                        style: _getTextFieldTextStyle(),
                                        decoration: _getTextFieldDecoration(
                                            'Channel name'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 28, right: 28, bottom: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Please provide a channel name and optional channel icon',
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          height: 48,
                          child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      Get.find<AddChannelCubit>()
                                          .showEmoijKeyBoard(false);
                                    }
                                  },
                                  child: TextFormField(
                                      controller: _descriptionEditingController,
                                      cursorColor: Colors.black,
                                      style: _getTextFieldTextStyle(),
                                      decoration: _getTextFieldDecoration(
                                          'Channel description')),
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 28, right: 28, bottom: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Please provide an optional decription for your channel',
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("CHANNEL TYPE",
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 16, right: 16),
                        child: BlocBuilder<AddChannelCubit, AddChannelState>(
                          bloc: Get.find<AddChannelCubit>(),
                          buildWhen: (_, currentState) =>
                              currentState is AddChannelValidation,
                          builder: (context, addChannelState) =>
                              SelectableChannelTypeWidget(
                            channelVisibility:
                                addChannelState.channelVisibility,
                            onSelectableChannelTypeClick: (channelVisibility) =>
                                Get.find<AddChannelCubit>()
                                    .setChannelVisibility(channelVisibility),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 28, right: 28, bottom: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Public channels can be found by everyone, though private can only be joined by invitation',
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 12),
                        child: BlocBuilder<AddChannelCubit, AddChannelState>(
                            bloc: Get.find<AddChannelCubit>(),
                            builder: (context, addChannelState) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "INVITED MEMBERS (${addChannelState.selectedMembers.length})",
                                  style: TextStyle(
                                    color: Color(0xff969ca4),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              );
                            }),
                      ),
                      _buildAddMemberRow(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: BlocBuilder<AddChannelCubit, AddChannelState>(
                          bloc: Get.find<AddChannelCubit>(),
                          builder: (context, addChannelState) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, index) => SizedBox(
                                height: 8,
                              ),
                              itemCount: addChannelState.selectedMembers.length,
                              itemBuilder: (context, index) {
                                final member =
                                    addChannelState.selectedMembers[index];
                                return SelectedMemberTile(
                                    onSelectedMemberTileClick: () {
                                      Get.find<AddChannelCubit>()
                                          .removeSelectedMember(member);
                                    },
                                    memberName: '${member.fullName}');
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                )),
                BlocBuilder<AddChannelCubit, AddChannelState>(
                    bloc: Get.find<AddChannelCubit>(),
                    builder: (context, addChannelState) {
                      if (addChannelState is AddChannelValidation &&
                          addChannelState.showEmoijKeyboard) {
                        return Container(
                          height: 250,
                          child: EmojiPicker(
                            onEmojiSelected: (cat, emoji) {
                              Get.find<AddChannelCubit>()
                                  .setEmoijIcon(emoji.emoji);
                              Future.delayed(
                                Duration(milliseconds: 50),
                                FocusManager.instance.primaryFocus?.unfocus,
                              );
                            },
                            config: Config(
                              columns: 7,
                              emojiSizeMax: 32.0,
                              verticalSpacing: 0,
                              horizontalSpacing: 0,
                              initCategory: Category.RECENT,
                              bgColor: Color(0xFFF2F2F2),
                              indicatorColor: Colors.blue,
                              iconColor: Colors.grey,
                              iconColorSelected: Colors.blue,
                              progressIndicatorColor: Colors.blue,
                              showRecentsTab: true,
                              recentsLimit: 28,
                              noRecentsText: "No Recents",
                              noRecentsStyle: const TextStyle(
                                  fontSize: 20, color: Colors.black26),
                              categoryIcons: const CategoryIcons(),
                              buttonMode: ButtonMode.MATERIAL,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMemberRow() {
    return BlocBuilder<AddChannelCubit, AddChannelState>(
        bloc: Get.find<AddChannelCubit>(),
        builder: (context, addChannelState) {
          return GestureDetector(
            onTap: () async {
              final currentSelectedMembers =
                  Get.find<AddChannelCubit>().state.selectedMembers;
              final selectedMembersResult = await push(
                  RoutePaths.addAndEditChannelMembers.path,
                  arguments: currentSelectedMembers.isEmpty
                      ? null
                      : currentSelectedMembers);
              if (selectedMembersResult != null) {
                Get.find<AddChannelCubit>()
                    .addSelectedMembers(selectedMembersResult);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.add_circle,
                          color: Color(0xff004dff),
                          size: 24,
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
            ),
          );
        });
  }

  Widget _buildSelectedChannelIcon(String emoij) {
    return GestureDetector(
      onTap: () => Get.find<AddChannelCubit>().showEmoijKeyBoard(true),
      child: ClipOval(
          child: Container(
        width: 56,
        height: 56,
        color: Color(0xfff2f2f6),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            emoij,
            style: TextStyle(fontSize: 30),
          ),
        ),
      )),
    );
  }

  InputDecoration _getTextFieldDecoration(String hintText) => InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.all(0),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Color(0xffc8c8c8),
        fontSize: 15,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      ));

  TextStyle _getTextFieldTextStyle() => const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
      );
}
