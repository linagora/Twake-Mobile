// import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/channels_provider.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
// import 'package:twake_mobile/screens/channels_screen.dart';
import 'package:twake_mobile/screens/messages_screen.dart';
import 'package:twake_mobile/screens/thread_screen.dart';
import 'package:twake_mobile/services/twake_api.dart';

class NotificationsHandler {
  final BuildContext context;
  final logger = Logger();
  FirebaseMessaging _fcm = FirebaseMessaging();
  ProfileProvider profile;
  MessagesProvider messagesProvider;
  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    logger.d('Message received\n$message');
    final data = message['data'];
    final channelId = data['channel_id'];
    final messageId = data['message_id'];
    final threadId = data['thread_id'];
    messagesProvider.getMessageOnUpdate(
      channelId: channelId,
      messageId: messageId,
      threadId: threadId,
    );
  }

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    print('on background message $message');
  }

  Future<void> navigateToMessage({
    String companyId,
    String workspaceId,
    String channelId,
    String threadId,
  }) async {
    profile.currentCompanySet(companyId, notify: false);
    profile.currentWorkspaceSet(workspaceId, notify: false);
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    await channelsProvider.loadChannels(
      Provider.of<TwakeApi>(context, listen: false),
      profile.selectedWorkspace.id,
      companyId: profile.selectedCompany.id,
    );
    messagesProvider.clearMessages();
    final navigator = Navigator.of(context);
    navigator.popUntil(
      ModalRoute.withName('/'),
    ); // navigator.popAndPushNamed(
    navigator.pushNamed(
      MessagesScreen.route,
      arguments: channelId,
    );
    if (threadId != null) {
      // give some time for the messages to be fetched
      // await Future.delayed(Duration(milliseconds: 300));
      navigator.pushNamed(
        ThreadScreen.route,
        arguments: {
          'channelId': channelId,
          'messageId': threadId,
        },
      );
    }
    // MessagesScreen.route,
    // );
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    logger.d('Resuming on message received\n$message');
    final data = message['data'];
    final channelId = data['channel_id'];
    final companyId = data['company_id'];
    final workspaceId = data['workspace_id'];
    final threadId = data['thread_id'];
    navigateToMessage(
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
    );
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    // wait before it app launches
    await Future.delayed(Duration(milliseconds: 500));
    logger.d('Navigating after fresh start $message');
    // delegate to existing function DRY
    onResume(message);
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
      logger.d('(DEBUG) FCM TOKEN: $token');
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
