import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/edit_channel_cubit/edit_channel_cubit.dart';
import 'package:twake/blocs/channels_cubit/edit_channel_cubit/edit_channel_state.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/widgets/common/enable_button_widget.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/pick_image_widget.dart';

class EditChannelWidget extends StatefulWidget {
  @override
  _EditChannelWidgetState createState() => _EditChannelWidgetState();
}

class _EditChannelWidgetState extends State<EditChannelWidget> {
  final _nameEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  late final Channel? _currentChannel;

  @override
  void initState() {
    super.initState();
    _currentChannel = Get.arguments;
    _nameEditingController.text = _currentChannel?.name ?? '';
    _descriptionEditingController.text = _currentChannel?.description ?? '';
    Get.find<EditChannelCubit>().setEmoijIcon(_currentChannel?.icon ?? '');
    Get.find<EditChannelCubit>()
        .validateEditChannelData(name: _currentChannel?.name ?? '');
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _descriptionEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // dismiss keyboard when tap outside
          FocusManager.instance.primaryFocus?.unfocus();
          Get.find<EditChannelCubit>().showEmoijKeyBoard(false);
        },
        child: SafeArea(
          bottom: false,
          child: Container(
            color: Color(0xfff2f2f6),
            child: Column(
              children: [
                BlocListener<EditChannelCubit, EditChannelState>(
                  bloc: Get.find<EditChannelCubit>(),
                  listenWhen: (previousState, currentState) {
                    return currentState is EditChannelSuccess ||
                        currentState is EditChannelFailure;
                  },
                  listener: (context, state) {
                    if (state is EditChannelSuccess) {
                      popBack();
                    } else if (state is EditChannelFailure) {
                      Get.find<EditChannelCubit>().validateEditChannelData(
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
                        child: IconButton(
                            onPressed: () => popBack(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xff004dff),
                            )),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BlocBuilder<EditChannelCubit, EditChannelState>(
                          bloc: Get.find<EditChannelCubit>(),
                          builder: (context, editChannelState) {
                            return EnableButtonWidget(
                                onEnableButtonWidgetClick: () {
                                  if (_currentChannel != null) {
                                    Get.find<EditChannelCubit>().editChannel(
                                        currentChannel: _currentChannel!,
                                        name: _nameEditingController.text,
                                        description:
                                            _descriptionEditingController.text,
                                        icon: editChannelState.emoijIcon);
                                  }
                                },
                                text: 'Save',
                                isEnable: (editChannelState
                                            is EditChannelValidation &&
                                        editChannelState.validToEditChannel)
                                    ? true
                                    : false);
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Channel info',
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
                            left: 28, right: 28, bottom: 0, top: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('CHANNEL NAME',
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 8),
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
                                  BlocBuilder<EditChannelCubit,
                                          EditChannelState>(
                                      bloc: Get.find<EditChannelCubit>(),
                                      builder: (context, editChannelState) {
                                        if (editChannelState
                                            .emoijIcon.isNotEmpty) {
                                          return _buildSelectedChannelIcon(
                                              editChannelState.emoijIcon);
                                        }
                                        return PickImageWidget(
                                            onPickImageWidgetClick: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          Get.find<EditChannelCubit>()
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
                                          Get.find<EditChannelCubit>()
                                              .showEmoijKeyBoard(false);
                                        }
                                      },
                                      child: TextFormField(
                                        onFieldSubmitted: (_) => FocusManager
                                            .instance.primaryFocus
                                            ?.nextFocus(),
                                        textInputAction: TextInputAction.next,
                                        onChanged: (text) =>
                                            Get.find<EditChannelCubit>()
                                                .validateEditChannelData(
                                                    name: text),
                                        controller: _nameEditingController,
                                        cursorColor: Colors.black,
                                        style: _getTextFieldTextStyle(),
                                        decoration: _getTextFieldDecoration(
                                          AppLocalizations.of(context)!
                                              .channelName,
                                        ),
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
                            left: 28, right: 28, bottom: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('CHANNEL DESCRIPTION',
                              style: TextStyle(
                                color: Color(0xff969ca4),
                                fontSize: 14,
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
                                      Get.find<EditChannelCubit>()
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
                    ],
                  ),
                )),
                BlocBuilder<EditChannelCubit, EditChannelState>(
                    bloc: Get.find<EditChannelCubit>(),
                    builder: (context, editChannelState) {
                      if (editChannelState is EditChannelValidation &&
                          editChannelState.showEmoijKeyboard) {
                        return Container(
                          height: 250,
                          child: EmojiPicker(
                            onEmojiSelected: (cat, emoji) {
                              Get.find<EditChannelCubit>()
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

  Widget _buildSelectedChannelIcon(String emoij) {
    return GestureDetector(
        onTap: () => Get.find<EditChannelCubit>().showEmoijKeyBoard(true),
        child: ImageWidget(
          imageType: ImageType.channel,
          imageUrl: Emojis.getByName(emoij),
          size: 56,
        ));
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
