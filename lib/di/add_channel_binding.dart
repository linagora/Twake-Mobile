
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_channel_cubit/add_channel_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/repositories/channels_repository.dart';

class AddChannelBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AddChannelCubit(
        channelsRepository: ChannelsRepository(),
        channelsCubit: Get.find<ChannelsCubit>()));
  }
}
