import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/di/add_member_binding.dart';
import 'package:twake/di/add_channel_binding.dart';
import 'package:twake/di/channel_file_binding.dart';
import 'package:twake/di/channel_setting_binding.dart';
import 'package:twake/di/edit_channel_binding.dart';
import 'package:twake/di/magic_link_binding.dart';
import 'package:twake/di/member_management_binding.dart';
import 'package:twake/di/new_direct_binding.dart';
import 'package:twake/pages/account/account_info.dart';
import 'package:twake/pages/account/account_settings.dart';
import 'package:twake/pages/account/select_theme.dart';
import 'package:twake/pages/channel/channel_detail/channel_detail_widget.dart';
import 'package:twake/pages/channel/channel_files/channel_files_widget.dart';
import 'package:twake/pages/channel/channel_settings/channel_settings_widget.dart';
import 'package:twake/pages/channel/edit_channel/edit_channel_widget.dart';
import 'package:twake/pages/channel/new_channel/new_channel_widget.dart';
import 'package:twake/pages/channel/new_direct/new_direct_chat_widget.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/chat/file_preview.dart';
import 'package:twake/pages/home/home_widget.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/pages/magic_link/invitation_people_by_email_page.dart';
import 'package:twake/pages/magic_link/invitation_people_page.dart';
import 'package:twake/pages/member/add_and_edit_member_widget.dart';
import 'package:twake/pages/member/member_management/member_management_widget.dart';
import 'package:twake/pages/chat/thread_page.dart';
import 'package:twake/pages/account/select_language.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_list_channel_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_list_company_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_file_list_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_file_widget.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_list_ws_widget.dart';
import 'package:twake/pages/workspaces/create_workspace.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/camera_view.dart';
import 'package:twake/utils/display_camera_picture.dart';
import 'package:twake/widgets/common/pinned_messages.dart';

final routePages = [
  GetPage(
    name: RoutePaths.initial,
    page: () => InitialPage(),
    children: [
      GetPage(
          name: RoutePaths.channelMessages.name,
          page: () => Chat<ChannelsCubit>(),
          transition: Transition.native,
          children: [
            GetPage(
              name: RoutePaths.channelPinnedMessages.name,
              page: () => PinnedMessages(),
              transition: Transition.native,
            ),
            GetPage(
                name: RoutePaths.cameraView.name,
                page: () => CameraView(),
                transition: Transition.native,
                children: [
                  GetPage(
                    name: RoutePaths.cameraPictureView.name,
                    page: () => DisplayCameraPictureScreen(),
                    transition: Transition.native,
                  ),
                ]),
            GetPage(
                name: RoutePaths.channelDetail.name,
                page: () => ChannelDetailWidget(),
                transition: Transition.native,
                children: [
                  GetPage(
                      name: RoutePaths.editChannel.name,
                      page: () => EditChannelWidget(),
                      transition: Transition.native,
                      binding: EditChannelBinding()),
                  GetPage(
                      name: RoutePaths.channelSettings.name,
                      page: () => ChannelSettingsWidget(),
                      transition: Transition.native,
                      binding: ChannelSettingBinding()),
                  GetPage(
                      name: RoutePaths.channelMemberManagement.name,
                      page: () => MemberManagementWidget(),
                      transition: Transition.native,
                      binding: MemberManagementBinding(),
                      children: [
                        GetPage(
                            name: RoutePaths.addChannelMembers.name,
                            page: () => AddAndEditMemberWidget(
                                  addAndEditMemberType:
                                      AddAndEditMemberType.addNewMember,
                                ),
                            transition: Transition.native,
                            binding: AddMemberBinding())
                      ]),
                  GetPage(
                    name: RoutePaths.channelFiles.name,
                    page: () => ChannelFilesWidget(),
                    transition: Transition.native,
                    binding: ChannelFileBinding(),
                  ),
                ]),
          ]),
      GetPage(
          name: RoutePaths.newDirect.name,
          page: () => NewDirectChatWidget(),
          binding: NewDirectBinding(),
          children: [
            GetPage(
                name: RoutePaths.addAndEditDirectMembers.name,
                page: () => AddAndEditMemberWidget(
                    addAndEditMemberType: AddAndEditMemberType.createDirect),
                transition: Transition.native,
                binding: AddMemberBinding()),
            GetPage(
                name: RoutePaths.newChannel.name,
                page: () => NewChannelWidget(),
                transition: Transition.native,
                binding: AddChannelBinding(),
                children: [
                  GetPage(
                      name: RoutePaths.addAndEditChannelMembers.name,
                      page: () => AddAndEditMemberWidget(),
                      transition: Transition.native,
                      binding: AddMemberBinding()),
                ])
          ]),
      GetPage(
        name: RoutePaths.directMessages.name,
        page: () => Chat<DirectsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: RoutePaths.channelMessageThread.name,
        page: () => ThreadPage<ChannelsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: RoutePaths.directMessageThread.name,
        page: () => ThreadPage<DirectsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
          name: RoutePaths.accountSettings.name,
          page: () => AccountSettings(),
          transition: Transition.native,
          children: [
            GetPage(
              name: RoutePaths.accountLanguage.name,
              page: () => SelectLanguage(),
              transition: Transition.native,
            ),
            GetPage(
              name: RoutePaths.accountTheme.name,
              page: () => SelectTheme(),
              transition: Transition.native,
            ),
          ]),
      GetPage(
        name: RoutePaths.accountInfo.name,
        page: () => AccountInfo(),
        transition: Transition.native,
      ),
      GetPage(
        name: RoutePaths.createWorkspace.name,
        page: () => WorkspaceForm(),
        transition: Transition.native,
      ),
      GetPage(
          name: RoutePaths.homeWidget.name,
          page: () => HomeWidget(),
          transition: Transition.native,
          children: [
            GetPage(
                name: RoutePaths.shareFile.name,
                page: () => ReceiveSharingFileWidget(),
                transition: Transition.native,
                children: [
                  GetPage(
                    name: RoutePaths.shareFileList.name,
                    page: () => ReceiveSharingFileListWidget(),
                    transition: Transition.native,
                  ),
                  GetPage(
                    name: RoutePaths.shareFileCompList.name,
                    page: () => ReceiveSharingCompanyListWidget(),
                    transition: Transition.native,
                  ),
                  GetPage(
                    name: RoutePaths.shareFileWsList.name,
                    page: () => ReceiveSharingWSListWidget(),
                    transition: Transition.native,
                  ),
                  GetPage(
                    name: RoutePaths.shareFileChannelList.name,
                    page: () => ReceiveSharingChannelListWidget(),
                    transition: Transition.native,
                  ),
                ])
          ]),
      GetPage(
        name: RoutePaths.signInUpScreen.name,
        page: () => HomeWidget(),
        transition: Transition.native,
      ),
      GetPage(
          name: RoutePaths.invitationPeople.name,
          page: () => InvitationPeoplePage(),
          transition: Transition.native,
          children: [
            GetPage(
              name: RoutePaths.invitationPeopleEmail.name,
              page: () => InvitationPeopleEmailPage(),
              transition: Transition.native,
              binding: MagicLinkBinding(),
            )
          ]),
      GetPage(
        name: RoutePaths.channelFilePreview.name,
        page: () => FilePreview<ChannelsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: RoutePaths.directFilePreview.name,
        page: () => FilePreview<DirectsCubit>(),
        transition: Transition.native,
      ),
    ],
  ),
];
