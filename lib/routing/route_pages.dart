import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/pages/account/account_settings.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/initial_page.dart';
import 'package:twake/pages/thread_page.dart';

final routePages = [
  GetPage(
    name: '/initial',
    page: () => InitialPage(),
    children: [
      GetPage(
        name: '/channel/messages',
        page: () => Chat<ChannelsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: '/direct/messages',
        page: () => Chat<DirectsCubit>(),
        transition: Transition.native,
      ),
      GetPage(
        name: '/account_settings',
        page: () => AccountSettings(),
        transition: Transition.native,
      ),
      GetPage(
        name: '/account_settings/account_info',
        page: () => AccountSettings(),
        transition: Transition.native,
      ),
    ],
  ),
];
