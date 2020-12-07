// import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
// import 'package:twake_mobile/screens/channels_screen.dart';
import 'package:twake_mobile/screens/messages_screen.dart';

class NotificationsHandler {
  final BuildContext context;
  FirebaseMessaging _fcm = FirebaseMessaging();
  ProfileProvider profile;
  MessagesProvider messagesProvider;
  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    print('Message received\n$message');
    final data = message['data'];
    final channelId = data['channel_id'];
    final messageId = data['message_id'];
    final parentMessageId = data['parent_message_id'];
    messagesProvider.getMessageOnUpdate(
      channelId: channelId,
      messageId: messageId,
      parentMessageId: parentMessageId,
    );
  }

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    print('on background message $message');
  }

  void navigateToMessage({
    String companyId,
    String workspaceId,
    String channelId,
  }) {
    profile.currentCompanySet(companyId, notify: false);
    profile.currentWorkspaceSet(workspaceId, notify: false);
    messagesProvider.clearMessages();
    final navigator = Navigator.of(context);
    navigator.popUntil(
      ModalRoute.withName('/'),
    ); // navigator.popAndPushNamed(
    navigator.pushNamed(
      MessagesScreen.route,
      arguments: channelId,
    );
    // MessagesScreen.route,
    // );
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    print('Resuming on message received\n$message');
    final data = message['data'];
    final channelId = data['channel_id'];
    final companyId = data['company_id'];
    final workspaceId = data['workspace_id'];
    navigateToMessage(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
    );
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print('on launch $message');
  }

  // void iOSPermission() {
  // _fcm.requestNotificationPermissions(
  // IosNotificationSettings(sound: true, badge: true, alert: true));
  // _fcm.onIosSettingsRegistered
  // .listen((IosNotificationSettings settings) {
  // print("Settings registered: $settings");
  // });
  // }
  NotificationsHandler({this.context}) {
    profile = Provider.of<ProfileProvider>(context, listen: false);
    messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    _fcm.getToken().then((token) {
      print('(DEBUG) FCM TOKEN: $token');
    });

    // if (Platform.isIOS) iOSPermission();

    _fcm.configure(
      onMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
      onResume: onResume,
      onLaunch: onLaunch,
    );
  }
}
