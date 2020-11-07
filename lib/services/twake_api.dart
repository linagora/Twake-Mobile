import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class TwakeApi with ChangeNotifier {
  String _authJWToken;
  bool isAuthorized = false;
  String _platform;
  TwakeApi() {
    _platform = Platform.isAndroid ? 'android' : 'apple';
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
      isAuthorized = true;
      notifyListeners();
    } catch (error) {
      print('ERROR ON API CALL $error');
      throw error;
    }
  }

  Future<Map<String, dynamic>> currentProfileGet() async {
    try {
      final response = await http.get(
        _TwakeApiConfig.currentProfileMethod,
        headers: _TwakeApiConfig.authHeader(_authJWToken),
      );
      final Map<String, dynamic> userData = jsonDecode(response.body);
      return userData;
    } catch (error) {
      print('WARNING! $error');
      throw error;
    }
  }

  Future<List<dynamic>> workspaceChannelsGet(String workspaceId) async {
    try {
      final response = await http.get(
        _TwakeApiConfig.workspaceChannelsMethod(workspaceId),
        headers: _TwakeApiConfig.authHeader(_authJWToken),
      );
      final channels = jsonDecode(response.body);
      // Some processing ...
      return channels;
    } catch (error) {
      print('Error occured while getting channels\n$error');
      throw error;
    }
  }
}

class _TwakeApiConfig {
  static const String _HOST = 'http://purecode.ru:3123';
  static const String _authorize = '/authorize';
  static const String _usersCurrentGet = '/users/current/get';
  static const String _workspaceChannels = '/workspace/%s/channels';

  static Map<String, String> authHeader(token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  static String get authorizeMethod {
    return _HOST + _authorize;
  }

  static String get currentProfileMethod {
    return _HOST + _usersCurrentGet;
  }

  static String workspaceChannelsMethod(String id) {
    return _HOST + sprintf(_workspaceChannels, id);
  }
}
