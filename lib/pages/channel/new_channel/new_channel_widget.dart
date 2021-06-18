import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_cubit.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_state.dart';
import 'package:twake/widgets/common/enable_button_widget.dart';
import 'package:twake/widgets/common/pick_image_widget.dart';
import 'package:twake/widgets/common/rounded_widget.dart';
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
  final _emoijEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emoijEditingController.addListener(() {
      print('hello?');
      if (_emoijEditingController.text.isNotEmpty) {
        Get.find<AddChannelCubit>().setEmoijIcon(_emoijEditingController.text);
      }
    });
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _descriptionEditingController.dispose();
    _emoijEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xfff2f2f6),
        body: GestureDetector(
          onTap: () {
            // dismiss keyboard when tap outside
            FocusManager.instance.primaryFocus?.unfocus();
            Get.find<AddChannelCubit>().showEmoijKeyBoard(false);
          },
          child: Container(
            color: Colors.black,
            child: RoundedWidget(
              useSafeArea: true,
              roundedTopOnly: true,
              child: Container(
                color: Color(0xfff2f2f6),
                child: Column(
                  children: [
                    BlocListener<AddChannelCubit, AddChannelState>(
                      bloc: Get.find<AddChannelCubit>(),
                      listener: (context, state) {
                        if (state is AddChannelSuccess) {
                          popBack();
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
                                        Get.find<AddChannelCubit>().create(name: _nameEditingController.text),
                                    text: 'Create',
                                    isEnable: (addChannelState is AddChannelValidation &&
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
                    Expanded(child: SingleChildScrollView(
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
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                              height: 80,
                              // color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Container(
                                  child: Row(
                                    children: [
                                      PickImageWidget(
                                        onPickImageWidgetClick: () =>
                                            Get.find<AddChannelCubit>().showEmoijKeyBoard(true),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Flexible(
                                        child: TextFormField(
                                          onChanged: (text) =>
                                              Get.find<AddChannelCubit>()
                                                  .validateAddChannelData(name: text),
                                          controller: _nameEditingController,
                                          cursorColor: Colors.black,
                                          style: _getTextFieldTextStyle(),
                                          decoration:
                                          _getTextFieldDecoration('Channel name'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 28, right: 28, bottom: 24),
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
                            padding:
                            const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                              height: 48,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: TextFormField(
                                        controller: _descriptionEditingController,
                                        cursorColor: Colors.black,
                                        style: _getTextFieldTextStyle(),
                                        decoration: _getTextFieldDecoration(
                                            'Channel description')),
                                  )),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 28, right: 28, bottom: 24),
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
                            padding:
                            const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
                            child: SelectableChannelTypeWidget(
                              channelVisibility: Get.find<AddChannelCubit>().channelVisibility,
                              onSelectableChannelTypeClick: (channelVisibility) =>
                                  Get.find<AddChannelCubit>().setChannelVisibility(channelVisibility),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 28, right: 28, bottom: 24),
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
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("INVITED MEMBERS (3)",
                                  style: TextStyle(
                                    color: Color(0xff969ca4),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    )),

                    BlocBuilder<AddChannelCubit, AddChannelState>(
                      bloc: Get.find<AddChannelCubit>(),
                        builder: (context, addChannelState) {
                          if (addChannelState is AddChannelValidation && addChannelState.showEmoijKeyboard) {
                            return EmojiKeyboard(bromotionController: _emoijEditingController);
                          }
                          return SizedBox.shrink();
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _getTextFieldDecoration(String hintText) =>
      InputDecoration(
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
