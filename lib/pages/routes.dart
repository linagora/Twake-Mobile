import 'package:flutter/material.dart';
import 'package:twake/pages/main_page.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/pages/thread_page.dart';

class Routes {
  static const root = '/';
  // static const main = '/main';
  static const messages = '/messages';
  static const thread = '/thread';

  static MaterialPageRoute onGenerateRoute(String routeName) {
    Widget page;
    switch (routeName) {
      case Routes.root:
      // case Routes.main:
        page = MainPage();
        break;
      case Routes.messages:
        page = MessagesPage();
        break;
      case Routes.thread:
        page = ThreadPage();
        break;
      default:
        throw 'Unknown route';
    }
    return MaterialPageRoute(builder: (ctx) => page);
  }
}
