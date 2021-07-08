import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channel_settings_cubit/channel_setting_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';

class ChannelSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ChannelSettingCubit(channelsCubit: Get.find<ChannelsCubit>()));
  }
}
