import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/services/service_bundle.dart';

import 'channels_type.dart';
import 'tabs.dart';

export 'channels_type.dart';
export 'tabs.dart';

part 'globals.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Globals extends BaseModel {
  static late Globals _globals;

  String host;

  Future<bool> hostSet(String val) async {
    final oldHost = host;

    host = val;
    try {
      await ApiService.instance.get(endpoint: Endpoint.version);
    } catch (e) {
      Logger().w('Host is invalid: $val');
      host = oldHost;
      return false;
    }
    save();
    return true;
  }

  String? companyId;
  // Use this setter to set the value, otherwise it will not persist
  set companyIdSet(String val) {
    companyId = val;
    save();
  }

  String? workspaceId;
  // Use this setter to set the value, otherwise it will not persist
  set workspaceIdSet(String? val) {
    workspaceId = val;
    save();
  }

  String? channelId;
  // Use this setter to set the value, otherwise it will not persist
  set channelIdSet(String? val) {
    channelId = val;
    save();
  }

  String? threadId;
  set threadIdSet(String? val) {
    threadId = val;
    save();
  }

  // type of the channels selected in main chats view: commons (public/private) or directs
  @JsonKey(defaultValue: ChannelsType.Commons)
  ChannelsType channelsType;
  // Use this setter to set the value, otherwise it will not persist
  set channelsTypeSet(ChannelsType val) {
    channelsType = val;
    save();
  }

  // tab which is currently selected in lower part of the app screen
  @JsonKey(defaultValue: Tabs.Channels)
  Tabs tabs;
  // Use this setter to set the value, otherwise it will not persist
  set tabsSet(Tabs val) {
    tabs = val;
    save();
  }

  // JWToken
  String? token;
  // Use this setter to set the value, otherwise it will not persist
  set tokenSet(String val) {
    token = val;
    save();
  }

  String fcmToken;
  // Use this setter to set the value, otherwise it will not persist
  set fcmTokenSet(String val) {
    fcmToken = val;
    save();
  }

  String? userId;
  // Use this setter to set the value, otherwise it will not persist
  set userIdSet(String val) {
    userId = val;
    save();
  }

  @JsonKey(ignore: true)
  bool isNetworkConnected = true;
  @JsonKey(ignore: true)
  final _connection = StreamController<Connection>.broadcast();
  Stream<Connection> get connection => _connection.stream;

  // Make sure to call the factory constructor before accessing instance
  static Globals get instance {
    return _globals;
  }

  factory Globals({
    required String host,
    ChannelsType channelsType: ChannelsType.Commons,
    Tabs tabs: Tabs.Channels,
    String? token,
    required String fcmToken,
    String? userId,
    String? companyId,
    String? workspaceId,
    String? channelId,
    String? threadId,
  }) {
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    if (!host.startsWith('http')) {
      host = 'https://$host';
    }
    _globals = Globals._(
      host: host,
      channelsType: channelsType,
      tabs: tabs,
      token: token,
      fcmToken: fcmToken,
      userId: userId,
      companyId: companyId,
      workspaceId: workspaceId,
      channelId: channelId,
      threadId: threadId,
    );

    return _globals;
  }

  Globals._({
    required this.host,
    required this.channelsType,
    required this.tabs,
    this.token,
    required this.fcmToken,
    this.userId,
    this.companyId,
    this.workspaceId,
    this.channelId,
    this.threadId,
  }) {
    // set up connection listener
    void onConnectionChange(ConnectivityResult state) {
      switch (state) {
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          ApiService.instance.get(endpoint: Endpoint.version).then((_) {
            if (!isNetworkConnected) {
              isNetworkConnected = true;
              _connection.sink.add(Connection.connected);
            }
          }).onError((e, _) {
            Logger().e('Coudn\'t connect to host:\n$e');
            if (isNetworkConnected) {
              isNetworkConnected = false;
              _connection.sink.add(Connection.disconnected);
            }
          });
          break;
        case ConnectivityResult.none:
          if (isNetworkConnected) {
            isNetworkConnected = false;
            _connection.sink.add(Connection.disconnected);
          }
      }
    }

    Connectivity().onConnectivityChanged.listen(onConnectionChange);
  }

  Future<void> save() async {
    await StorageService.instance.cleanInsert(table: Table.globals, data: this);
  }

  void reset() {
    companyId = null;
    workspaceId = null;
    channelId = null;
    threadId = null;
    token = null;
    userId = null;
  }

  factory Globals.fromJson(Map<String, dynamic> json) {
    _globals = _$GlobalsFromJson(json);
    return _globals;
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) => _$GlobalsToJson(this);

  void closeStream() async {
    await _connection.close();
  }
}

enum Connection { connected, disconnected }
