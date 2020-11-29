import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake_mobile/services/twake_api.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message extends JsonSerializable with ChangeNotifier {
  @JsonKey(required: true)
  final String id;

  @JsonKey(name: 'responses_count')
  int responsesCount;

  @JsonKey(required: true)
  final Sender sender;

  @JsonKey(required: true, name: 'creation_date')
  final int creationDate;

  @JsonKey(required: true)
  final MessageTwacode content;

  Map<String, dynamic> reactions;

  List<Message> responses;

  @JsonKey(ignore: true)
  String channelId;

  Message({
    @required this.id,
    this.responsesCount,
    this.sender,
    this.creationDate,
    this.content,
    this.reactions,
    this.responses,
  });

  void updateReactions({
    String emojiCode,
    String userId,
    TwakeApi api,
  }) {
    if (emojiCode == null) return;
    api.reactionSend(this.channelId, this.id, emojiCode).then((_) {
      if (reactions == null) {
        reactions = {};
      }
      // If user has already reacted to this message then
      // we just remove him from reacted users only to readd him
      // with a different Emoji
      final previousEmoji = _userReactedWith(emojiCode, userId);
      if (previousEmoji != null) {
        List<String> users = reactions[previousEmoji]['users'];
        reactions[previousEmoji]['count']--;
        users.remove(userId);
        if (users.isEmpty) {
          reactions.remove(previousEmoji);
        }
      }
      // In case if someone already reacted with this emoji, keep working with it
      if (reactions[emojiCode] != null) {
        // Get the list of people, who reacted with this emoji
        List<String> users = reactions[emojiCode]['users'];
        // If user already reacted with this emoji, then decrement the count
        // and remove the user from list
        if (users.contains(userId)) {
          reactions[emojiCode]['count']--;
          users.remove(userId);
          if (users.isEmpty) {
            reactions.remove(emojiCode);
          }
          if (reactions.isEmpty) {
            reactions = null;
          }
        } else {
          // otherwise increment count and add the user
          reactions[emojiCode]['count']++;
          users.add(userId);
        }
      } // otherwise create a new entry and populate with data
      else {
        reactions[emojiCode] = {
          'users': [userId],
          'count': 1,
        };
      }
      notifyListeners();
    });
  }

  // Helper method to check, if the user has already reacted with different emoji
  String _userReactedWith(String emojiCode, String userId) {
    bool reacted = false;
    String _emojiCode;
    final emojis = reactions.keys;
    for (int i = 0; i < emojis.length; i++) {
      final users = reactions[emojis.elementAt(i)]['users'] as List<String>;
      reacted = users.contains(userId);
      if (reacted) {
        if (emojis.elementAt(i) != emojiCode) {
          _emojiCode = emojis.elementAt(i);
        }
        break;
      }
    }
    return _emojiCode;
  }

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// channelId is saved on per message basis in order to save and retrieve
  /// messages from data store later.
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$MessageToJson(this);
    // Channel Id should be set explicitly, because of ignore JSONKEY
    map['channelId'] = this.channelId;
    return map;
  }
}

@JsonSerializable()
class MessageTwacode {
  @JsonKey(name: 'original_str')
  final String originalStr;

  // @JsonKey(required: true)
  final List<dynamic> prepared;

  MessageTwacode({
    this.originalStr,
    this.prepared,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory MessageTwacode.fromJson(Map<String, dynamic> json) =>
      _$MessageTwacodeFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$MessageTwacodeToJson(this);
}

@JsonSerializable()
class Sender {
  @JsonKey(required: true)
  final String username;

  final String img;

  final String id;

  @JsonKey(name: 'firstname')
  final String firstName;

  @JsonKey(name: 'lastname')
  final String lastName;

  Sender({
    @required this.username,
    this.img,
    this.id,
    this.firstName,
    this.lastName,
  });

  /// Convenience methods to avoid serializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() => _$SenderToJson(this);
}
