import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/services/service_bundle.dart';

import 'twacode.dart';
export 'twacode.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message extends CollectionItem {
  @JsonKey(required: true)
  String id;

  @JsonKey(name: 'thread_id')
  String threadId;

  @JsonKey(name: 'responses_count', defaultValue: 0)
  int responsesCount;

  @JsonKey(ignore: true)
  String get respCountStr =>
      responsesCount == 0 ? 'No' : responsesCount.toString();

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'app_id')
  final String appId;

  @JsonKey(required: true, name: 'creation_date')
  int creationDate;

  @JsonKey(required: true)
  MessageTwacode content;

  @JsonKey(defaultValue: [])
  List<Map<String, dynamic>> reactions;

  @JsonKey(required: true, name: 'channel_id')
  String channelId;

  @JsonKey(name: 'is_selected', defaultValue: 0)
  int isSelected;

  String username;
  @JsonKey(name: 'firstname')
  String firstName;
  @JsonKey(name: 'lastname')
  String lastName;
  String thumbnail;
  @JsonKey(name: 'name')
  String appName;

  @JsonKey(ignore: true)
  final _api = Api();

  @JsonKey(ignore: true)
  final logger = Logger();

  @JsonKey(ignore: true)
  final _storage = Storage();

  int get key {
    return (this.content.originalStr ?? '').hashCode +
        this.reactions.map((r) => r['name']).join().hashCode +
        this.reactions.fold(0, (acc, r) => acc + r['count']) +
        this.id.hashCode;
  }

  String get sender {
    if (userId != null) {
      return firstName.isNotEmpty
          ? '$firstName $lastName'
          : username[0].toUpperCase() + username.substring(1);
    } else // message is sent by bot
      return appName;
  }

  Message({
    this.id,
    this.userId,
    this.appId,
    this.creationDate,
    this.threadId,
    this.content,
    this.channelId,
    this.responsesCount,
    this.reactions,
    this.username,
    this.lastName,
    this.firstName,
    this.thumbnail,
  }) : super(id);

  void updateContent(Map<String, dynamic> body) {
    logger.d('UPDATING MESSAGE CONTENT');
    String prevStr = '' + content.originalStr;
    content.originalStr = body['original_str'];
    content.prepared = body['prepared'];
    _api.put(Endpoint.messages, body: body).then((_) => save()).catchError((e) {
      logger.e('ERROR updating message content\n$e');
      content.originalStr = prevStr;
    });
  }

  void updateReactions({String userId, Map<String, dynamic> body}) {
    String emojiCode = body['reaction'];
    logger.d('Updating reaction: $emojiCode');
    if (emojiCode == null) return;
    final oldReactions = List.from(reactions);
    for (var r in reactions) {
      final users = r['users'] as List;
      if (users.contains(userId)) {
        logger.d('Found userId: $users');
        users.remove(userId);
        r['count'] -= 1;
        if (users.isEmpty) reactions.removeWhere((v) => v['name'] == r['name']);
        if (emojiCode == r['name']) {
          emojiCode = '';
          body['reaction'] = '';
        }
        break;
      }
    }
    if (emojiCode.isNotEmpty) {
      final r = reactions.firstWhere((r) => r['name'] == emojiCode,
          orElse: () => {'name': emojiCode, 'users': [], 'count': 0});
      r['users'].add(userId);
      r['count'] += 1;
    }

    _api.post(Endpoint.reactions, body: body).then((_) {
      save();
      logger.d('Successfully updated reaction\n$reactions');
    }).catchError((_) {
      logger.e('Error updating reaction');
      reactions = oldReactions;
    });
  }

  Future<void> save() async {
    await _storage.store(
      item: this.toJson(),
      type: StorageType.Message,
      key: id,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    json = Map.from(json);
    // print('Reactions: ${json['reactions']}');
    if (json['content'] is String) {
      json['content'] = jsonDecode(json['content']);
    }
    if (json['reactions'] is String) {
      json['reactions'] = jsonDecode(json['reactions']);
    } else if (json['reactions'] is Map) {
      json['reactions'] = [json['reactions']];
    }
    return _$MessageFromJson(json);
  }

  Map<String, dynamic> toJson() {
    var map = _$MessageToJson(this);
    map['content'] = jsonEncode(map['content']);
    map['reactions'] = jsonEncode(map['reactions']);
    map.remove('username');
    map.remove('thumbnail');
    map.remove('lastname');
    map.remove('firstname');
    map.remove('name');
    return map;
  }
}
