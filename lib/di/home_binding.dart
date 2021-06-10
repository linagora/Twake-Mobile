import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/services/navigator_service.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthenticationCubit(), permanent: true);
    Get.put(WorkspacesCubit(), permanent: true);
    Get.put(CompaniesCubit(), permanent: true);
    Get.put(ChannelsCubit(), permanent: true);
    Get.put(DirectsCubit(), permanent: true);
    Get.put(ChannelMessagesCubit(), permanent: true);
    Get.put(ThreadMessagesCubit(), permanent: true);

    NavigatorService(
      companiesCubit: Get.find<CompaniesCubit>(),
      workspacesCubit: Get.find<WorkspacesCubit>(),
      channelsCubit: Get.find<ChannelsCubit>(),
      directsCubit: Get.find<DirectsCubit>(),
      channelMessagesCubit: Get.find<ChannelMessagesCubit>(),
      threadMessagesCubit: Get.find<ThreadMessagesCubit>(),
    );
  }
}
