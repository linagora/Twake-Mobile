import 'package:get/get.dart';
import 'package:twake/pages/workspaces_management/workspaces_management.dart';
import 'package:twake/routing/route_paths.dart';

final routePages = [
  GetPage(
      name: RoutePaths.workspacesManagement,
      page: () => WorkspacesManagement(),
      transition: Transition.native),
];
