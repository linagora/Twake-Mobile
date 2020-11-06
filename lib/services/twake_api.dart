import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class TwakeApi with ChangeNotifier {
  String _authJWToken;
  bool isAuthorized = false;

  Future<void> authenticate(String username, String password) async {
    try {
      var response = await http.post(
        _TwakeApiConfig.authorizeMethod,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'username': username,
            'password': password,
          },
        ),
      );
      var authData = jsonDecode(response.body);
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
      var response = await http.get(
        _TwakeApiConfig.currentProfileMethod,
        headers: {
          'Authorization': 'Bearer $_authJWToken',
        },
      );
      final Map<String, dynamic> userData = jsonDecode(response.body);
      return userData;
    } catch (error) {
      print('WARNING! $error');
      throw error;
    }
  }
}

class _TwakeApiConfig {
  static const String _HOST = 'http://purecode.ru:3123';
  static const String _authorize = '/authorize';
  static const String _usersCurrentGet = '/users/current/get';
  static const String _workspaceChannels = '/workspace/%s/channels';

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
