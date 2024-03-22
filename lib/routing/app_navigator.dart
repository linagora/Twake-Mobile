import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/pages/home/home_widget.dart';
import 'package:twake/routing/navigation_info.dart';

class AppNavigator {
  // NavigationInfo _navigationInfo;

  Future<void> navigateToHome({WorkspaceJoinResponse? magicLinkJoinResponse}) async {
    Get.offAll(() => HomeWidget(magicLinkJoinResponse: magicLinkJoinResponse),
      transition: Transition.native,
    );
  }

  void _updateNavigationInfo(NavigationInfo navigationInfo) {

  }
}