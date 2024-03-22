import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/features/app_cubit.dart';
import 'package:twake/routing/app_navigator.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppCubit());
    Get.lazyPut(() => AuthenticationCubit());
    Get.lazyPut(() => AppNavigator());
  }
}