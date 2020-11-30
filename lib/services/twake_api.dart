import 'dart:convert' show jsonEncode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
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
  // TODO get rid of this, request right data from api
  Dio dio;
  Map<String, dynamic> _userData;
  TwakeApi() {
    DB.authLoad().then((map) {
      fromMap(map);
      validate().then((_) {
        dio = Dio(BaseOptions(
          headers: TwakeApiConfig.authHeader(_authJWToken),
        ));
        notifyListeners();
      });
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

  void fromJson(Map<String, dynamic> json) {
    _authJWToken = json['token'];
    _tokenExpiration =
        DateTime.fromMillisecondsSinceEpoch(json['expiration'] * 1000);
    _refreshToken = json['refresh_token'];
    _refreshExpiration =
        DateTime.fromMillisecondsSinceEpoch(json['refresh_expiration'] * 1000);
  }

  Future<void> validate() async {
    final now = DateTime.now().toLocal();
    if (now.isAfter(_tokenExpiration.toLocal())) {
      if (now.isAfter(_refreshExpiration.toLocal())) {
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
      final response = await dio.post(
        TwakeApiConfig.tokenProlongMethod,
        data: jsonEncode(
          {
            'refresh_token': refreshToken,
            'timezoneoffset': timeZoneOffset,
          },
        ),
      );
      print('TOKEN DATA:${response.data}');
      fromJson(response.data);
      if (_authJWToken == null) {
        throw Exception('Authorization failed');
      }
      _isAuthorized = true;
      dio = Dio(
        BaseOptions(headers: TwakeApiConfig.authHeader(_authJWToken)),
      );
      DB.authSave(this);
      notifyListeners();
    } catch (error) {
      print('Error occurred during authentication\n$error');
      throw error;
    }
  }

  Future<void> authenticate(String username, String password) async {
    try {
      final response = await dio.post(
        TwakeApiConfig.authorizeMethod,
        data: jsonEncode(
          {
            'username': username,
            'password': password,
            'device': _platform,
            'timezoneoffset': '$timeZoneOffset'
          },
        ),
      );
      fromJson(response.data);
      if (_authJWToken == null) {
        throw Exception('Authorization failed');
      }
      _isAuthorized = true;
      dio = Dio(
        BaseOptions(headers: TwakeApiConfig.authHeader(_authJWToken)),
      );
      DB.authSave(this);
      notifyListeners();
    } catch (error) {
      print('Error occurred during authentication\n$error');
      throw error;
    }
  }

  Future<Map<String, dynamic>> currentProfileGet() async {
    await validate();
    try {
      print('AUTH TOKEN USED: $_authJWToken');
      final response = await dio.get(
        TwakeApiConfig.currentProfileMethod, // url
      );
      print('AUTH TOKEN USED: $_authJWToken');
      _userData = response.data;
      return _userData;
    } catch (error) {
      print('Error occurred while loading user profile\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> workspaceChannelsGet(String workspaceId) async {
    await validate();
    try {
      final response = await dio.get(
        TwakeApiConfig.workspaceChannelsMethod(workspaceId), // url
      );
      return response.data;
    } catch (error) {
      print('Error occurred while getting workspace channels\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> directMessagesGet(String companyId) async {
    await validate();
    try {
      final response = await dio.get(
        TwakeApiConfig.directMessagesMethod(companyId),
      );
      if (response.statusCode != 200) return [];
      return response.data;
    } catch (error) {
      print('Error occurred while getting direct messages\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> channelMessagesGet(
    String channelId, {
    String beforeMessageId,
  }) async {
    await validate();
    try {
      final response = await dio.get(
        TwakeApiConfig.channelMessagesMethod(
          channelId,
          beforeId: beforeMessageId,
        ), // url
      );
      return response.data;
    } catch (error) {
      print('Error occurred while getting channel messages\n$error');
      throw error;
    }
  }

  Future<void> messageSend({
    String channelId,
    String content,
    String parentMessageId,
    Function(Map<String, dynamic>) onSuccess,
  }) async {
    await validate();
    final body = jsonEncode({
      'original_str': content,
      'parent_message_id': parentMessageId ?? '',
    });
    try {
      final response = await dio.post(
        TwakeApiConfig.channelMessagesMethod(channelId, isPost: true),
        data: body,
      );
      if (response.statusCode < 203) {
        var message = response.data['object'];
        // TODO remove after requesting data from api
        message['sender'] = {
          'username': _userData['username'],
          'thumbnail': _userData['thumbnail'],
          'userId': _userData['userId'],
          'firstname': _userData['firstname'],
          'lastname': _userData['lastname'],
        };
        message['reactions'] = null;
        print('MESSAGE $message');
        onSuccess(message);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> reactionSend(
    String channelId,
    String messageId,
    String reaction,
  ) async {
    await validate();
    try {
      final _ = await dio.post(
        TwakeApiConfig.messageReactionsMethod(channelId),
        data: jsonEncode({
          'reaction': reaction,
          'message_id': messageId,
        }),
      );
    } catch (error) {
      print('Error occurred while setting reaction\n$error');
    }
  }

  Future<void> messageDelete(String channelId, String messageId) async {
    await validate();
    final url = TwakeApiConfig.channelMessagesMethod(channelId, isPost: true);
    print('$url\n$messageId');
    try {
      final _ = await dio.delete(
        url,
        data: jsonEncode({
          'message_id': messageId,
        }),
      );
    } catch (error) {
      print('Error occurred while deteting message\n$error');
    }
  }
}
