import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channel_settings_cubit/channel_setting_cubit.dart';
import 'package:twake/blocs/channels_cubit/channel_settings_cubit/channel_setting_state.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/pages/channel/selectable_channel_type_widget.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/enable_button_widget.dart';

class ChannelSettingsWidget extends StatefulWidget {
  const ChannelSettingsWidget({Key? key}) : super(key: key);

  @override
  _ChannelSettingsWidgetState createState() => _ChannelSettingsWidgetState();
}

class _ChannelSettingsWidgetState extends State<ChannelSettingsWidget> {
  late final Channel? _currentChannel;

  @override
  void initState() {
    super.initState();
    _currentChannel = Get.arguments;
    if (_currentChannel != null) {
      Get.find<ChannelSettingCubit>()
          .setChannelVisibility(_currentChannel, _currentChannel!.visibility);
    }
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
                BlocListener<ChannelSettingCubit, ChannelSettingState>(
                  bloc: Get.find<ChannelSettingCubit>(),
                  listenWhen: (previousState, currentState) {
                    return currentState is ChannelSettingSuccess ||
                        currentState is ChannelSettingFailure;
                  },
                  listener: (context, state) {
                    if (state is ChannelSettingSuccess) {
                      popBack();
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
                        child: IconButton(
                            onPressed: () => popBack(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Theme.of(context).colorScheme.surface,
                            )),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BlocBuilder<ChannelSettingCubit,
                            ChannelSettingState>(
                          bloc: Get.find<ChannelSettingCubit>(),
                          builder: (context, editChannelState) {
                            return Container(
                              alignment: Alignment.centerRight,
                              width: 120,
                              child: EnableButtonWidget(
                                  onEnableButtonWidgetClick: () {
                                    if (_currentChannel != null) {
                                      Get.find<ChannelSettingCubit>()
                                          .editChannel(
                                              currentChannel: _currentChannel!);
                                    }
                                  },
                                  text: AppLocalizations.of(context)!.save,
                                  isEnable:
                                      editChannelState.validToEditChannel),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          width: 170,
                          child: AutoSizeText(
                            AppLocalizations.of(context)!.channelSettings,
                            maxLines: 1,
                            maxFontSize: 17,
                            minFontSize: 12,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 17),
                          ),
                        ),
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
                            left: 16, bottom: 12, top: 16),
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
                        child: BlocBuilder<ChannelSettingCubit,
                            ChannelSettingState>(
                          bloc: Get.find<ChannelSettingCubit>(),
                          buildWhen: (_, currentState) =>
                              currentState is ChannelSettingInSettingState,
                          builder: (context, addChannelState) =>
                              SelectableChannelTypeWidget(
                            channelVisibility:
                                addChannelState.channelVisibility,
                            onSelectableChannelTypeClick: (channelVisibility) =>
                                Get.find<ChannelSettingCubit>()
                                    .setChannelVisibility(
                                        _currentChannel, channelVisibility),
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
                    ],
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
