// import 'dart:io';
import 'dart:convert';
import 'dart:io';
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

class NotificationData{
  final String companyId;
  final String workspaceId;
  final String channelId;
  final String threadId;
  final String messageId;
  NotificationData({this.companyId, this.workspaceId, this.channelId, this.threadId, this.messageId});
}



class NotificationsHandler {
  final BuildContext context;
  final logger = Logger();
  FirebaseMessaging _fcm = FirebaseMessaging();
  ProfileProvider profile;
  MessagesProvider messagesProvider;

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    logger.d('Message received\n$message');
    // print('Message received\n$message');

    var data = {};

    try {
      data = jsonDecode(message['notification_data']);
    } catch (e) {
      data = jsonDecode(message['data']['notification_data']);
    }

    // var data = jsonDecode(message['data']['notification_data']);
    try {
      if (data == null) {
        data = message['data'];
      }

      String channelId = data['channel_id'];
      // Monkey patch
      // https://github.com/TwakeApp/Mobile/issues/99
      if (channelId[14] == '1') {
        channelId = channelId.replaceRange(14, 15, '4');
      }

      logger.d("ok, that's what we have:");
      logger.d(data);

      String threadId = data['thread_id'];
      if (threadId.isEmpty) {
        threadId = null;
      }

      var notificationData = new NotificationData(
          companyId:data['company_id'],
          workspaceId: data['workspace_id'],
          channelId: data['channel_id'],
          threadId:threadId,
          messageId: data['message_id']);

      messagesProvider.getMessageOnUpdate(notificationData);
    } catch (error) {
      print('$error');
    }
  }

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    print('on background message $message');
  }

  Future<void> navigateToMessage(NotificationData notificationData) async {
    profile.currentCompanySet(notificationData.companyId, notify: false);
    profile.currentWorkspaceSet(notificationData.workspaceId, notify: false);
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
      arguments: notificationData.channelId,
    );
    if (notificationData.threadId != null) {
      // give some time for the messages to be fetched
      // await Future.delayed(Duration(milliseconds: 300));
      navigator.pushNamed(
        ThreadScreen.route,
        arguments: {
          'channelId': notificationData.channelId,
          'messageId': notificationData.threadId,
        },
      );
    }
    // MessagesScreen.route,
    // );
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    logger.w('Resuming on message received\n$message');
    final data = message['data'];
    navigateToMessage(new NotificationData(
        channelId : data['channel_id'],
        companyId : data['company_id'],
        workspaceId : data['workspace_id'],
        threadId : data['thread_id']
    ));
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    // wait before it app launches
    await Future.delayed(Duration(milliseconds: 500));
    logger.w('Navigating after fresh start $message');
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
      print('(DEBUG) FCM TOKEN: $token');
    });

    // if (Platform.isIOS) iOSPermission();

    _fcm.configure(
      onMessage: onMessage,
      onBackgroundMessage: Platform.isIOS ? null : onBackgroundMessage,
      onResume: onResume,
      onLaunch: onLaunch,
    );
  }
}
