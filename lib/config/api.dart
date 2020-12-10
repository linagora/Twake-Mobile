import 'package:package_info/package_info.dart';

class TwakeApiConfig {
  static const String _HOST = 'https://mobile.api.twake.app';
  static const String _authorize = '/authorize';
  static const String _usersCurrentGet = '/user';
  static const String _workspaceChannels = '/channels';
  static const String _channelMessages = '/messages';
  static const String _tokenProlong = '/authorization/prolong';
  static const String _directMessages = '/direct';
  static const String _messageReactions = '/reactions';
  static String apiVersion;

  static Map<String, String> authHeader(token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json',
      'Accept-version': apiVersion,
    };
  }

  static Future<void> init() async {
    apiVersion = (await PackageInfo.fromPlatform()).version;
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
}
