import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/workspaces_management/workspaces_management.dart';
import 'package:twake/routing/route_paths.dart';

final routePages = [
  GetPage(
    name: RoutePaths.workspacesManagement,
    page: () => WorkspacesManagement(),
    transition: Transition.native,
  ),
  GetPage(
    name: RoutePaths.channelMessages,
    page: () => Chat<ChannelsCubit>(),
    transition: Transition.native,
  ),
  GetPage(
    name: RoutePaths.directMessages,
    page: () => Chat<DirectsCubit>(),
    transition: Transition.native,
  ),
];
