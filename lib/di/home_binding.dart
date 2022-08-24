import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_cubit.dart';
import 'package:twake/blocs/camera_cubit/camera_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/blocs/file_cubit/file_transition_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/blocs/language_cubit/language_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_cubit/invitation_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/joining_cubit/joining_cubit.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/registration_cubit/registration_cubit.dart';
import 'package:twake/blocs/theme_cubit/theme_cubit.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/receive_sharing_file_manager.dart';
import 'package:twake/utils/receive_sharing_text_manager.dart';

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

    final channelUnreadMessagesCubit =
        ChannelUnreadMessagesCubit(channelsCubit: channelsCubit, directsCubit: directsCubit);
    Get.put(channelUnreadMessagesCubit, permanent: true);

    final threadUnreadMessagesCubit = ThreadUnreadMessagesCubit(
        channelUnreadMessagesCubit: channelUnreadMessagesCubit,
        channelsCubit: channelsCubit);
    Get.put(threadUnreadMessagesCubit, permanent: true);

    final channelMessagesCubit = ChannelMessagesCubit(
        channelsCubit: channelsCubit,
        directsCubit: directsCubit,
        unreadMessagesCubit: channelUnreadMessagesCubit);
    Get.put(channelMessagesCubit, permanent: true);

    final threadMessagesCubit =
        ThreadMessagesCubit(unreadMessageCubit: threadUnreadMessagesCubit);
    Get.put(threadMessagesCubit, permanent: true);

    final pinnedMessagesCubit = PinnedMessageCubit();
    Get.put(pinnedMessagesCubit, permanent: true);

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

    final cacheInChatCubit = CacheInChatCubit();
    Get.put(cacheInChatCubit, permanent: true);

    final themeCubit = ThemeCubit();
    Get.put(themeCubit, permanent: true);

    final joiningCubit = JoiningCubit();
    Get.put(joiningCubit, permanent: true);

    final receiveFileCubit = ReceiveFileCubit();
    Get.put(receiveFileCubit, permanent: true);

    final receiveFileSharingManager = ReceiveSharingFileManager();
    Get.put(receiveFileSharingManager, permanent: true);

    final receiveTextSharingManager = ReceiveSharingTextManager();
    Get.put(receiveTextSharingManager, permanent: true);

    final cameraCubit = CameraCubit();
    Get.put(cameraCubit, permanent: true);

    final galleryCubit = GalleryCubit();
    Get.put(galleryCubit, permanent: true);

    final companyFileCubit = CompanyFileCubit(accountCubit: accountCubit);
    Get.put(companyFileCubit, permanent: true);

    final fileUploadTransitionCubit = FileTransitionCubit();
    Get.put(fileUploadTransitionCubit, permanent: true);
    
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
      pinnedMessageCubit: pinnedMessagesCubit,
      badgesCubit: badgesCubit,
    );
  }
}
