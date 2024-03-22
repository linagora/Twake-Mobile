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
import 'package:twake/blocs/message_animation_cubit/message_animation_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/online_status_cubit/online_status_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/blocs/quote_message_cubit/quote_message_cubit.dart';
import 'package:twake/blocs/receive_file_cubit/receive_file_cubit.dart';
import 'package:twake/blocs/registration_cubit/registration_cubit.dart';
import 'package:twake/blocs/search_cubit/search_cubit.dart';
import 'package:twake/blocs/theme_cubit/theme_cubit.dart';
import 'package:twake/blocs/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/writing_cubit/writing_cubit.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/receive_sharing_file_manager.dart';
import 'package:twake/utils/receive_sharing_text_manager.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {

    final companiesCubit = CompaniesCubit();
    Get.put(companiesCubit, permanent: true);

    final workspacesCubit = WorkspacesCubit();
    Get.put(workspacesCubit, permanent: true);

    Get.put(MentionsCubit(), permanent: true);

    Get.put(FileCubit(), permanent: true);

    final fileUploadCubit = FileUploadCubit();
    Get.put(fileUploadCubit, permanent: true);

    Get.put(FileDownloadCubit(), permanent: true);

    final channelsCubit = ChannelsCubit();
    Get.put(channelsCubit, permanent: true);

    final directsCubit = DirectsCubit();
    Get.put(directsCubit, permanent: true);

    final channelUnreadMessagesCubit = ChannelUnreadMessagesCubit(
        channelsCubit: channelsCubit, directsCubit: directsCubit);
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

    Get.put(LanguageCubit(), permanent: true);

    Get.put(InvitationCubit(), permanent: true);

    Get.put(CacheInChatCubit(), permanent: true);

    Get.put(ThemeCubit(), permanent: true);

    Get.put(JoiningCubit(), permanent: true);

    Get.put(ReceiveFileCubit(), permanent: true);

    Get.put(ReceiveSharingFileManager(), permanent: true);

    Get.put(ReceiveSharingTextManager(), permanent: true);

    Get.put(CameraCubit(), permanent: true);

    Get.put(GalleryCubit(), permanent: true);

    final companyFileCubit = CompanyFileCubit(accountCubit: accountCubit);
    Get.put(companyFileCubit, permanent: true);

    Get.put(
        FileTransitionCubit(
            channelMessagesCubit, threadMessagesCubit, fileUploadCubit),
        permanent: true);

    Get.put(MessageAnimationCubit(), permanent: true);

    Get.put(QuoteMessageCubit(), permanent: true);

    Get.put(WritingCubit(), permanent: true);

    Get.put(OnlineStatusCubit(), permanent: true);

    final searchCubit = SearchCubit.initWithRepository();
    Get.put(searchCubit, permanent: true);

    Future.delayed(Duration(seconds: 5), () {
      if (Globals.instance.token != null) Get.find<AuthenticationCubit>().registerDevice();
    });

    Get.put(NavigatorService(
      accountCubit: accountCubit,
      companiesCubit: companiesCubit,
      workspacesCubit: workspacesCubit,
      channelsCubit: channelsCubit,
      directsCubit: directsCubit,
      channelMessagesCubit: channelMessagesCubit,
      threadMessagesCubit: threadMessagesCubit,
      pinnedMessageCubit: pinnedMessagesCubit,
      badgesCubit: badgesCubit,
    ));
  }
}
