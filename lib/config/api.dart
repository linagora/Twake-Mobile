import 'package:package_info/package_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TwakeApiConfig {
  static const String _HOST = 'https://mobile.api.twake.app';
  // static const String _HOST = 'http://192.168.1.52:3123';
  static const String _authorize = '/authorize';
  static const String _usersCurrentGet = '/user';
  static const String _workspaceChannels = '/channels';
  static const String _channelMessages = '/messages';
  static const String _tokenProlong = '/authorization/prolong';
  static const String _directMessages = '/direct';
  static const String _messageReactions = '/reactions';
  static const String _settingsEmojis = '/settings/emoji';
  static const String _companies = '/companies';
  static const String _workspaces = '/workspaces';
  static String apiVersion;
  static String fcmToken;

  static Map<String, String> authHeader(token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json',
      'Accept-version': apiVersion,
    };
  }

  static Future<void> init() async {
    apiVersion = (await PackageInfo.fromPlatform()).version;
    fcmToken = (await FirebaseMessaging().getToken());
  }

  static String get authorizeMethod {
    return _HOST + _authorize;
  }

  static String get currentProfileMethod {
    return _HOST + _usersCurrentGet + '?timezoneoffset=3';
  }

  static String get workspaceChannelsMethod {
    return _HOST + _workspaceChannels;
  }

  static String get channelMessagesMethod {
    var url = _HOST + _channelMessages;
    return url;
  }

  static String get directMessagesMethod {
    return _HOST + _directMessages;
  }

  /// Method for getting url, in order to prolong JWToken
  static String get tokenProlongMethod {
    return _HOST + _tokenProlong;
  }

  /// Method for getting url, in order to update message reactions
  static String get messageReactionsMethod {
    return _HOST + _messageReactions;
  }

  /// Method for getting up to date version of emoji map
  static String get settingsEmoji {
    return _HOST + _settingsEmojis;
  }

  static String get workspacesMethod {
    return _HOST + _workspaces;
  }

  static String get companiesMethod {
    return _HOST + _companies;
  }
}
