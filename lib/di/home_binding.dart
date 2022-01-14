import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/cache_file_cubit/cache_file_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/lenguage_cubit/language_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_cubit/invitation_cubit.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/registration_cubit/registration_cubit.dart';
import 'package:twake/blocs/theme_cubit/theme_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/globals/globals.dart';
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

    final fileUploadCubit = FileUploadCubit();
    Get.put(fileUploadCubit, permanent: true);

    final fileDownloadCubit = FileDownloadCubit();
    Get.put(fileDownloadCubit, permanent: true);

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

    final badgesCubit = BadgesCubit();
    Get.put(badgesCubit, permanent: true);

    final registratCubit = RegistrationCubit();
    Get.put(registratCubit, permanent: true);

    final languageCubit = LanguageCubit();
    Get.put(languageCubit, permanent: true);

    final invitationCubit = InvitationCubit();
    Get.put(invitationCubit, permanent: true);

    final cacheFileCubit = CacheFileCubit();
    Get.put(cacheFileCubit, permanent: true);

    final themeCubit = ThemeCubit();
    Get.put(themeCubit, permanent: true);

    Future.delayed(Duration(seconds: 5), () {
      if (Globals.instance.token != null) authenticationCubit.registerDevice();
    });

    NavigatorService(
      accountCubit: accountCubit,
      companiesCubit: companiesCubit,
      workspacesCubit: workspacesCubit,
      channelsCubit: channelsCubit,
      directsCubit: directsCubit,
      channelMessagesCubit: channelMessagesCubit,
      threadMessagesCubit: threadMessagesCubit,
      badgesCubit: badgesCubit,
    );
  }
}
