import 'package:flutter/material.dart';
import 'package:twake/pages/chat/chat.dart';
import 'package:twake/pages/server_configuration.dart';
import 'package:twake/pages/tabs_controller.dart';
import 'package:twake/pages/thread_page.dart';
import 'package:twake/pages/edit_channel.dart';
import 'package:twake/pages/profile/settings.dart';

class Routes {
  static const root = '/';
  static const messages = '/messages';
  static const thread = '/thread';
  static const editChannel = '/edit_channel';
  static const serverConfiguration = '/server_configuration';
  static const settings = '/settings';

  static MaterialPageRoute onGenerateRoute(String routeName) {
    Widget page;
    switch (routeName) {
      case Routes.root:
        // page = MainPage();
        page = TabsController();
        break;
      case Routes.messages:
        // page = MessagesPage();
        page = Chat();
        break;
      case Routes.thread:
        page = ThreadPage();
        break;
      case Routes.editChannel:
        page = EditChannel();
        break;
      case Routes.serverConfiguration:
        page = ServerConfiguration();
        break;
      case Routes.settings:
        page = Settings();
        break;
      default:
        throw 'Unknown route';
    }
    return MaterialPageRoute(builder: (ctx) => page);
  }
}
