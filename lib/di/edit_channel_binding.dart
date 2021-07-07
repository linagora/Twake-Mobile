import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/edit_channel_cubit/edit_channel_cubit.dart';

class EditChannelBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(EditChannelCubit(channelsCubit: Get.find<ChannelsCubit>()));
  }
}
