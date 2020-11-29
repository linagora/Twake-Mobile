import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/config/api.dart' show TwakeApiConfig;

/// Main class for interacting with Twake api
/// Contains all neccessary methods and error handling
class TwakeApi with ChangeNotifier {
  final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
  String _authJWToken;
  String _refreshToken;
  DateTime _tokenExpiration;
  DateTime _refreshExpiration;
  bool _isAuthorized = false;
  String _platform;
  TwakeApi() {
    DB.authLoad().then((map) {
      fromMap(map);
      notifyListeners();
    }).catchError((e) => print('Error loading auth data from database\n$e'));
    if (_authJWToken != null) {
      validate(); // Make sure we have an active token
    }
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
      'authJWToken': _authJWToken,
      'refreshToken': _refreshToken,
      'isAuthorized': _isAuthorized,
      'platform': _platform,
      'tokenExpiration': _tokenExpiration.toIso8601String(),
      'refreshExpiration': _refreshExpiration.toIso8601String(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    _authJWToken = map['authJWToken'];
    _refreshToken = map['refreshToken'];
    _tokenExpiration = DateTime.parse(map['tokenExpiration'] as String);
    _refreshExpiration = DateTime.parse(map['refreshExpiration'] as String);
    _isAuthorized = map['isAuthorized'];
    _platform = map['platform'];
  }

  void fromJson(String json) {
    final map = jsonDecode(json);
    _authJWToken = map['token'];
    _tokenExpiration =
        DateTime.fromMillisecondsSinceEpoch(map['expiration'] * 1000);
    _refreshToken = map['refresh_token'];
    _refreshExpiration =
        DateTime.fromMillisecondsSinceEpoch(map['refresh_expiration'] * 1000);
  }

  Future<void> validate() async {
    final now = DateTime.now().toLocal();
    if (now.isAfter(_tokenExpiration)) {
      if (now.isAfter(_refreshExpiration)) {
        _authJWToken = null;
        _refreshToken = null;
        _tokenExpiration = null;
        _refreshExpiration = null;
        _isAuthorized = false;
        DB.fullClean(); // clean up any data from store
        notifyListeners();
      } else {
        await prolongToken(_refreshToken);
      }
    }
    print(
        'Validation passed, expiration: ${_tokenExpiration.toLocal().toIso8601String()}');
  }

  Future<void> prolongToken(String refreshToken) async {
    try {
      print('Trying to prolongToken');
      final response = await http.post(
        TwakeApiConfig.tokenProlongMethod,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'refresh_token': refreshToken,
            'timezoneoffset': timeZoneOffset,
          },
        ),
      );
      fromJson(response.body);
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
            'timezoneoffset': '$timeZoneOffset'
          },
        ),
      );
      fromJson(response.body);
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
    await validate();
    try {
      final response = await http.get(
        TwakeApiConfig.currentProfileMethod, // url
        headers: TwakeApiConfig.authHeader(_authJWToken),
      );
      final Map<String, dynamic> userData = jsonDecode(response.body);
      print('GOT USER DATA:\n$userData');
      return userData;
    } catch (error) {
      print('Error occured while loading user profile\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> workspaceChannelsGet(String workspaceId) async {
    await validate();
    try {
      final response = await http.get(
        TwakeApiConfig.workspaceChannelsMethod(workspaceId), // url
        headers: TwakeApiConfig.authHeader(_authJWToken),
      );
      final channels = jsonDecode(response.body);
      // Some processing ...
      return channels;
    } catch (error) {
      print('Error occured while getting workspace channels\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> directMessagesGet(String companyId) async {
    await validate();
    try {
      final response = await http.get(
        TwakeApiConfig.directMessagesMethod(companyId),
        headers: TwakeApiConfig.authHeader(_authJWToken),
      );
      final directs = jsonDecode(response.body);
      return directs;
    } catch (error) {
      print('Error occured while getting direct messages\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> channelMessagesGet(
    String channelId, {
    String beforeMessageId,
  }) async {
    await validate();
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

  Future<void> messageSend(String channelId, String content,
      {String parentMessageId}) async {
    await validate();
    try {
      final response = await http.post(
        TwakeApiConfig.channelMessagesMethod(channelId, isPost: true),
        headers: TwakeApiConfig.authHeader(_authJWToken),
        body: jsonEncode(content),
      );
      print(response.body);
    } catch (error) {}
  }
}
