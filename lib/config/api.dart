import 'package:sprintf/sprintf.dart';

class TwakeApiConfig {
  static const String _HOST = 'http://purecode.ru:3123';
  static const String _authorize = '/authorize';
  static const String _usersCurrentGet = '/users/current/get';
  static const String _workspaceChannels = '/workspace/%s/channels';
  static const String _channelMessages = '/channels/%s/messages';

  static Map<String, String> authHeader(token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  static String get authorizeMethod {
    return _HOST + _authorize;
  }

  static String get currentProfileMethod {
    final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
    return _HOST + _usersCurrentGet + '?timezoneoffset=$timeZoneOffset';
  }

  static String workspaceChannelsMethod(String id) {
    return _HOST + sprintf(_workspaceChannels, [id]);
  }

  static String channelMessagesMethod(
    String channelId, {
    String beforeId,
    int limit,
  }) {
    var url = _HOST + sprintf(_channelMessages, [channelId]) + '?';
    if (beforeId != null) {
      url = url + 'before=$beforeId&';
    }
    if (limit != null) {
      url = url + 'limit=$limit&';
    }

    return url;
  }
}
