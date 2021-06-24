import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/di/AddMemberBinding.dart';
import 'package:twake/di/add_channel_binding.dart';
import 'package:twake/di/home_binding.dart';
import 'package:twake/pages/account/account_info.dart';
import 'package:twake/pages/account/account_settings.dart';
import 'package:twake/pages/channel/new_channel/new_channel_widget.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/home/home_widget.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/pages/member/add_and_edit_member_widget.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/pages/workspaces/create_workspace.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/widgets/sheets/add/workspace_info_form.dart';

final routePages = [
  GetPage(
    name: RoutePaths.initial,
    page: () => InitialPage(),
    children: [
      GetPage(
        name: RoutePaths.channelMessages.name,
        page: () => Chat<ChannelsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
          name: RoutePaths.newChannel.name,
          page: () => NewChannelWidget(),
          transition: Transition.native,
          binding: AddChannelBinding(),
          children: [
            GetPage(
                name: RoutePaths.addChannelMembers.name,
                page: () => AddAndEditMemberWidget(),
                transition: Transition.native,
                binding: AddMemberBinding()),
          ]),
      GetPage(
        name: RoutePaths.directMessages.name,
        page: () => Chat<DirectsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: RoutePaths.messageThread.name,
        page: () => ThreadPage<ChannelsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: RoutePaths.accountSettings.name,
        page: () => AccountSettings(),
        transition: Transition.native,
      ),
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
    ],
  ),
];
