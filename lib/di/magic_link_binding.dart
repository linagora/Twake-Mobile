import 'package:get/get.dart';
import 'package:twake/blocs/magic_link_cubit/invitation_email_cubit/invitation_email_cubit.dart';

class MagicLinkBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(InvitationEmailCubit());
  }

}