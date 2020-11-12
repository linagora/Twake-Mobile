import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class TwakeApi with ChangeNotifier {
  String _authJWToken;
  bool _isAuthorized = false;
  String _platform;
  TwakeApi() {
    _platform = Platform.isAndroid ? 'android' : 'apple';
  }

  String get token => _authJWToken;

  bool get isAuthorized => _isAuthorized;

  set isAuthorized(value) {
    _isAuthorized = value;
    notifyListeners();
  }

  Future<void> authenticate(String username, String password) async {
    try {
      final response = await http.post(
        _TwakeApiConfig.authorizeMethod,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'username': username,
            'password': password,
            'device': _platform,
          },
        ),
      );
      final authData = jsonDecode(response.body);
      _authJWToken = authData['token'];
      if (_authJWToken == null) {
        throw Exception('Authorization failed');
      }
      _isAuthorized = true;
      notifyListeners();
    } catch (error) {
      print('Error occured during authentication\n$error');
      throw error;
    }
  }

  Future<Map<String, dynamic>> currentProfileGet() async {
    try {
      final response = await http.get(
        _TwakeApiConfig.currentProfileMethod, // url
        headers: _TwakeApiConfig.authHeader(_authJWToken),
      );
      final Map<String, dynamic> userData = jsonDecode(response.body);
      return userData;
    } catch (error) {
      print('Error occured while loading user profile\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> workspaceChannelsGet(String workspaceId) async {
    try {
      final response = await http.get(
        _TwakeApiConfig.workspaceChannelsMethod(workspaceId), // url
        headers: _TwakeApiConfig.authHeader(_authJWToken),
      );
      final channels = jsonDecode(response.body);
      // Some processing ...
      return channels;
    } catch (error) {
      print('Error occured while getting workspace channels\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> channelMessagesGet(String channelId) async {
    try {
      final response = await http.get(
        _TwakeApiConfig.channelMessagesMethod(channelId), // url
        headers: _TwakeApiConfig.authHeader(_authJWToken),
      );
      final messages = jsonDecode(response.body);
      // Some processing ...
      return messages;
    } catch (error) {
      print('Error occured while getting channel messages\n$error');
      throw error;
    }
  }
}

class _TwakeApiConfig {
  static const String _HOST = 'http://10.0.2.2:3123';
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
