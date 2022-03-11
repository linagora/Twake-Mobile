import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channel_file_cubit/channel_file_cubit.dart';

class ChannelFileBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ChannelFileCubit());
  }

}