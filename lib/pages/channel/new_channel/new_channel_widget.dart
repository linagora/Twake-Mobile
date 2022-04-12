import 'package:auto_size_text/auto_size_text.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_cubit.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_state.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel_visibility.dart';
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
  bool addAllUsers = false;

  @override
  void dispose() {
    _nameEditingController.dispose();
    _descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments.runtimeType is List<Account>) {
      Get.find<AddChannelCubit>().addSelectedMembers(Get.arguments);
      Get.find<AddChannelCubit>()
          .setChannelVisibility(ChannelVisibility.private);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // dismiss keyboard when tap outside
          FocusManager.instance.primaryFocus?.unfocus();
          Get.find<AddChannelCubit>().showEmoijKeyBoard(false);
        },
        child: SafeArea(
          child: Container(
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
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          onPressed: () => popBack(),
                          child: Text(AppLocalizations.of(context)!.cancel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400)),
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
                                description: _descriptionEditingController.text,
                                isDefault: addAllUsers,
                              ),
                              text: AppLocalizations.of(context)!.create,
                              isEnable:
                                  (addChannelState is AddChannelValidation &&
                                          addChannelState.validToCreateChannel)
                                      ? true
                                      : false,
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(AppLocalizations.of(context)!.newChannel,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 17, fontWeight: FontWeight.w600)),
                      )
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondaryContainer,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          height: 80,
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
                                        cursorColor: Theme.of(context)
                                            .textSelectionTheme
                                            .cursorColor,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(30)
                                        ],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1!
                                            .copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15),
                                        decoration: _getTextFieldDecoration(
                                            AppLocalizations.of(context)!
                                                .channelName),
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
                              AppLocalizations.of(context)!
                                  .channelNameAndIconSuggestion,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
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
                                      cursorColor: Theme.of(context)
                                          .textSelectionTheme
                                          .cursorColor,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1!
                                          .copyWith(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15),
                                      decoration: _getTextFieldDecoration(
                                        AppLocalizations.of(context)!
                                            .channelDescription,
                                      )),
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
                              AppLocalizations.of(context)!
                                  .channelDescriptionSuggestion,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(AppLocalizations.of(context)!.channelType,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
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
                                {
                              Get.find<AddChannelCubit>()
                                  .setChannelVisibility(channelVisibility),
                              addAllUsers = false
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 28, right: 28, bottom: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              AppLocalizations.of(context)!.channelTypeInfo,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12)),
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
                                  "${AppLocalizations.of(context)!.invitedMembers} (${addChannelState.selectedMembers.length})",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                ),
                              );
                            }),
                      ),
                      BlocBuilder<AddChannelCubit, AddChannelState>(
                        bloc: Get.find<AddChannelCubit>(),
                        builder: (context, state) {
                          if (state.channelVisibility ==
                              ChannelVisibility.public) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 44,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: AutoSizeText(
                                                AppLocalizations.of(context)!
                                                    .inviteAllWorkspaceUsers,
                                                maxLines: 1,
                                                minFontSize: 15,
                                                maxFontSize: 17,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            CupertinoSwitch(
                                              activeColor: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .color,
                                              value: addAllUsers,
                                              onChanged: (bool value) {
                                                setState(() {
                                                  addAllUsers = value;
                                                  //print(addAllUsers);
                                                });
                                              },
                                            )
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
                                        AppLocalizations.of(context)!
                                            .automaticallyInviteAllWorkspaceUsers,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12)),
                                  ),
                                ),
                              ],
                            );
                          } else
                            return SizedBox.shrink();
                        },
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
                              bgColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              indicatorColor:
                                  Theme.of(context).colorScheme.surface,
                              iconColor:
                                  Theme.of(context).colorScheme.secondary,
                              iconColorSelected:
                                  Theme.of(context).colorScheme.surface,
                              progressIndicatorColor:
                                  Theme.of(context).colorScheme.surface,
                              showRecentsTab: true,
                              recentsLimit: 28,
                              noRecentsText:
                                  AppLocalizations.of(context)!.noRecents,
                              noRecentsStyle: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(fontSize: 20),
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
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).colorScheme.surface,
                          size: 24,
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.addMember,
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w400))
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
      hintStyle: Theme.of(context)
          .textTheme
          .headline2!
          .copyWith(fontSize: 15, fontWeight: FontWeight.w400));
}
