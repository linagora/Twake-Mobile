import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/services/navigator_service.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    final authenticationCubit = AuthenticationCubit();
    Get.put(authenticationCubit, permanent: true);

    final companiesCubit = CompaniesCubit();
    Get.put(companiesCubit, permanent: true);

    final workspacesCubit = WorkspacesCubit();
    Get.put(workspacesCubit, permanent: true);

    final mentionsCubit = MentionsCubit();
    Get.put(mentionsCubit, permanent: true);

    final fileCubit = FileCubit();
    Get.put(fileCubit, permanent: true);

    final channelsCubit = ChannelsCubit();
    Get.put(channelsCubit, permanent: true);

    final directsCubit = DirectsCubit();
    Get.put(directsCubit, permanent: true);

    final channelMessagesCubit = ChannelMessagesCubit();
    Get.put(channelMessagesCubit, permanent: true);

    final threadMessagesCubit = ThreadMessagesCubit();
    Get.put(threadMessagesCubit, permanent: true);

    final accountCubit = AccountCubit();
    Get.put(accountCubit, permanent: true);

    NavigatorService(
      accountCubit: accountCubit,
      companiesCubit: companiesCubit,
      workspacesCubit: workspacesCubit,
      channelsCubit: channelsCubit,
      directsCubit: directsCubit,
      channelMessagesCubit: channelMessagesCubit,
      threadMessagesCubit: threadMessagesCubit,
    );
  }
}
