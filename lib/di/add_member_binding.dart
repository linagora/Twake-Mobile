import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/add_member_cubit/add_member_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';

class AddMemberBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AddMemberCubit(
        workspacesCubit: Get.find<WorkspacesCubit>(),
        channelsCubit: Get.find<ChannelsCubit>()));
  }
}
