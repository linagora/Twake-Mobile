import 'dart:convert' show jsonEncode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/db.dart';
import 'package:twake_mobile/config/api.dart' show TwakeApiConfig;

const int _MESSAGES_PER_PAGE = 50;

/// Main class for interacting with Twake api
/// Contains all neccessary methods and error handling
class TwakeApi with ChangeNotifier {
  final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
  final logger = Logger();
  String _authJWToken;
  String _refreshToken;
  DateTime _tokenExpiration;
  DateTime _refreshExpiration;
  bool _isAuthorized = false;
  String _platform;
  // TODO get rid of this, request right data from api
  Dio dio = Dio();
  TwakeApi() {
    // Get version number for the app
    // Try to load state from local store
    // validate data
    TwakeApiConfig.init().then((_) => DB.authLoad().then((map) {
          fromMap(map);
          validate().then((_) {
            dio = Dio(BaseOptions(
              headers: TwakeApiConfig.authHeader(_authJWToken),
            ));
            notifyListeners();
          });
        }).catchError((e) {
          logger.e('Error loading auth data from database\n$e');
        }));
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
    logger.v(
        'Validation passed, expiration: ${_tokenExpiration.toLocal().toIso8601String()}');
  }

  Future<void> prolongToken(String refreshToken) async {
    try {
      logger.d('Trying to prolongToken');
      final response = await dio.post(
        TwakeApiConfig.tokenProlongMethod,
        data: jsonEncode(
          {
            'refresh_token': refreshToken,
            'timezoneoffset': timeZoneOffset,
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
    } catch (error, stackTrace) {
      logger.e('Error occurred during authentication\n${error.response.data}');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
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
    } catch (error, stackTrace) {
      logger.e('Error occurred during authentication\n${error.response.data}');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
      throw error;
    }
  }

  Future<Map<String, dynamic>> currentProfileGet() async {
    await validate();
    try {
      final response = await dio.get(
        TwakeApiConfig.currentProfileMethod, // url
      );
      return response.data;
    } catch (error) {
      logger.e('Error occurred while loading user profile\n$error');
      throw error;
    }
  }

  Future<List<dynamic>> workspaceChannelsGet(String workspaceId) async {
    await validate();
    try {
      final response = await dio.get(
        TwakeApiConfig.workspaceChannelsMethod, // url
        queryParameters: {
          'workspace_id': workspaceId,
        },
      );
      return response.data;
    } catch (error, stackTrace) {
      logger.e(
          'Error occurred while getting workspace channels\n${error.response.data}');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
      throw error;
    }
  }

  Future<List<dynamic>> directMessagesGet(String companyId) async {
    await validate();
    try {
      final response = await dio.get(
        TwakeApiConfig.directMessagesMethod,
        queryParameters: {
          'company_id': companyId,
        },
      );
      return response.data;
    } catch (error, stackTrace) {
      logger.e('Error occurred while getting direct channels\n$error');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
      throw error;
    }
  }

  Future<List<dynamic>> channelMessagesGet(
    String channelId, {
    String beforeMessageId,
    String threadId,
    String messageId,
  }) async {
    await validate();
    try {
      final profile = ProfileProvider(); // singleton
      final qp = {
        'company_id': profile.selectedCompany.id,
        'channel_id': channelId,
        'workspace_id': profile.selectedWorkspace.id,
        'before_message_id': beforeMessageId,
        'limit': messageId == null ? _MESSAGES_PER_PAGE : 1,
        'message_id': messageId,
        'thread_id': threadId,
      };

      final response = await dio.get(
        TwakeApiConfig.channelMessagesMethod, // url
        queryParameters: qp,
      );
      return response.data;
    } catch (error, stackTrace) {
      logger.e(
          'Error occurred while getting channel messages\n${error.response.data}');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
      throw error;
    }
  }

  Future<void> messageSend({
    String channelId,
    String content,
    String threadId,
    Function(Map<String, dynamic>) onSuccess,
  }) async {
    await validate();
    final profileProvider = ProfileProvider();
    final body = jsonEncode({
      'original_str': content,
      'company_id': profileProvider.selectedCompany.id,
      'workspace_id': profileProvider.selectedWorkspace.id,
      'channel_id': channelId,
      'thread_id': threadId,
    });
    try {
      final response = await dio.post(
        TwakeApiConfig.channelMessagesMethod,
        data: body,
      );
      var message = response.data;
      // TODO remove after requesting data from api
      final profile = profileProvider.currentProfile;
      message['responses'] = [];
      message['sender'] = {
        'username': profile.username,
        'thumbnail': profile.thumbnail,
        'userId': profile.userId,
        'firstname': profile.firstName,
        'lastname': profile.lastName,
      };
      message['reactions'] = null;
      onSuccess(message);
    } catch (error, stackTrace) {
      logger.e('ERROR OCCURED ON MESSAGE SEND: $error');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
      throw error;
    }
  }

  Future<void> reactionSend(
    String channelId,
    String messageId,
    String reaction, {
    String threadId,
  }) async {
    await validate();
    final profile = ProfileProvider();
    try {
      final data = jsonEncode({
        'company_id': profile.selectedCompany.id,
        'channel_id': channelId,
        'workspace_id': profile.selectedWorkspace.id,
        'reaction': reaction,
        'message_id': messageId,
        'thread_id': threadId,
      });
      final _ = await dio.post(
        TwakeApiConfig.messageReactionsMethod,
        data: data,
      );
    } catch (error, stackTrace) {
      logger.e('Error occurred while setting reaction\n$error');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
      throw error;
    }
  }

  Future<void> messageDelete(
    String channelId,
    String messageId, {
    String threadId,
  }) async {
    await validate();
    final url = TwakeApiConfig.channelMessagesMethod;
    final profile = ProfileProvider();
    try {
      final _ = await dio.delete(
        url,
        data: jsonEncode({
          'company_id': profile.selectedCompany.id,
          'channel_id': channelId,
          'workspace_id': profile.selectedWorkspace.id,
          'message_id': messageId,
          'thread_id': threadId,
        }),
      );
    } catch (error, stackTrace) {
      logger.e('Error occurred while deteting message\n${error.response.data}');
      // await Sentry.captureException(
      // error,
      // stackTrace: stackTrace,
      // );
    }
  }
}
