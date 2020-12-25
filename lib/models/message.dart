import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/services/service_bundle.dart';

import 'sender.dart';
import 'twacode.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  @JsonKey(name: 'thread_id')
  String threadId;

  @JsonKey(name: 'responses_count')
  int responsesCount;

  @JsonKey(required: true)
  final Sender sender;

  @JsonKey(required: true, name: 'creation_date')
  int creationDate;

  @JsonKey(required: true)
  MessageTwacode content;

  @JsonKey(defaultValue: {})
  Map<String, dynamic> reactions;

  @JsonKey(required: true)
  String channelId;

  // used when deleting messages
  // TODO try to remove this field
  @JsonKey(ignore: true)
  bool hidden = false;

  @JsonKey(ignore: true)
  final _api = Api();

  @JsonKey(ignore: true)
  final logger = Logger();

  @JsonKey(ignore: true)
  final _storage = Storage();

  Message({
    this.id,
    this.sender,
    this.creationDate,
    this.content,
  });

  void doPartialUpdate(Message other) {
    this.responsesCount = other.responsesCount;
    this.creationDate = other.creationDate;
    this.content = other.content;
    this.reactions = other.reactions;
  }

  void updateReactions({
    String userId,
    Map<String, dynamic> body,
  }) {
    String emojiCode = body['reaction'];
    if (emojiCode == null) return;
    final oldReactions = Map<String, dynamic>.from(reactions);
    // If user has already reacted to this message then
    // we just remove him from reacted users only to readd him
    // with a different Emoji
    for (var r in reactions.entries) {
      final users = r.value['users'] as List;
      if (users.contains(userId)) {
        users.remove(userId);
        if (users.isEmpty) reactions.remove(r.key);
        break;
      }
    }
    final r = reactions[emojiCode] ?? {'users': [], 'count': 0};
    r['users'].add(userId);
    r['count'] += 1;
    reactions[emojiCode] = r;

    _api
        .post(Endpoint.reactions, body: body)
        .catchError((_) => reactions = oldReactions)
        .whenComplete(() => save());
  }

  Future<void> save() async {
    await _storage.store(item: this, type: StorageType.Message, key: id);
  }

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Message.fromJson(Map<String, dynamic> json) {
    return _$MessageFromJson(json);
  }

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$MessageToJson(this);
    return map;
  }
}
