import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/di/add_member_binding.dart';
import 'package:twake/di/add_channel_binding.dart';
import 'package:twake/di/channel_setting_binding.dart';
import 'package:twake/di/edit_channel_binding.dart';
import 'package:twake/di/member_management_binding.dart';
import 'package:twake/di/new_direct_binding.dart';
import 'package:twake/pages/account/account_info.dart';
import 'package:twake/pages/account/account_settings.dart';
import 'package:twake/pages/channel/channel_detail/channel_detail_widget.dart';
import 'package:twake/pages/channel/channel_settings/channel_settings_widget.dart';
import 'package:twake/pages/channel/edit_channel/edit_channel_widget.dart';
import 'package:twake/pages/channel/new_channel/new_channel_widget.dart';
import 'package:twake/pages/channel/new_direct/new_direct_chat_widget.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/home/home_widget.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/pages/member/add_and_edit_member_widget.dart';
import 'package:twake/pages/member/member_management/member_management_widget.dart';
import 'package:twake/pages/chat/thread_page.dart';
import 'package:twake/pages/select_language.dart';
import 'package:twake/pages/workspaces/create_workspace.dart';
import 'package:twake/routing/route_paths.dart';

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
      ),
      GetPage(
        name: RoutePaths.signInUpScreen.name,
        page: () => HomeWidget(),
        transition: Transition.native,
      ),
    ],
  ),
];
