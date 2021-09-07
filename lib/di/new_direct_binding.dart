import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/channels_cubit/new_direct_cubit/new_direct_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/repositories/channels_repository.dart';

class NewDirectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NewDirectCubit(
        workspacesCubit: Get.find<WorkspacesCubit>(),
        accountCubit: Get.find<AccountCubit>(),
        directsCubit: Get.find<DirectsCubit>(),
        channelsRepository: ChannelsRepository()));
  }
}
