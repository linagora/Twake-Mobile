import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/config/api.dart' show TwakeApiConfig;

/// Main class for interacting with Twake api
/// Contains all neccessary methods and error handling
class TwakeApi with ChangeNotifier {
  String _authJWToken;
  bool _isAuthorized = false;
  String _platform;
  TwakeApi() {
    DB.authLoad().then((map) {
      fromMap(map);
      notifyListeners();
    }).catchError((e) => print('Error loading auth data from database\n$e'));
    _platform = Platform.isAndroid ? 'android' : 'apple';
  }

  String get token => _authJWToken;

  bool get isAuthorized => _isAuthorized;

  set isAuthorized(value) {
    _isAuthorized = value;
    DB.authClean();
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'authjwtoken': _authJWToken,
      'isauthorized': _isAuthorized ? 1 : 0,
      'platform': _platform,
    };
  }

  fromMap(Map<String, dynamic> map) {
    print('GOT DATA FOR AUTH:\n$map');
    _authJWToken = map['authjwtoken'];
    _isAuthorized = map['isauthorized'] == 1;
    _platform = map['platform'];
  }

  Future<void> authenticate(String username, String password) async {
    try {
      final response = await http.post(
        TwakeApiConfig.authorizeMethod,
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
      DB.authSave(this);
      notifyListeners();
    } catch (error) {
      print('Error occured during authentication\n$error');
      throw error;
    }
  }

  Future<Map<String, dynamic>> currentProfileGet() async {
    try {
      final response = await http.get(
        TwakeApiConfig.currentProfileMethod, // url
        headers: TwakeApiConfig.authHeader(_authJWToken),
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
        TwakeApiConfig.workspaceChannelsMethod(workspaceId), // url
        headers: TwakeApiConfig.authHeader(_authJWToken),
      );
      final channels = jsonDecode(response.body);
      print(channels);
      // Some processing ...
      return channels;
    } catch (error) {
      print('Error occured while getting workspace channels\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> channelMessagesGet(
    String channelId, {
    String beforeMessageId,
  }) async {
    try {
      final response = await http.get(
        TwakeApiConfig.channelMessagesMethod(
          channelId,
          beforeId: beforeMessageId,
        ), // url
        headers: TwakeApiConfig.authHeader(_authJWToken),
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
