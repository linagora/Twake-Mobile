import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';
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

  Map<String, dynamic> reactions;

  @JsonKey(ignore: true)
  bool responsesLoaded = false;

  @JsonKey(ignore: true)
  String channelId;

  // used when deleting messages
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
    String emojiCode,
    String userId,
  }) {
    if (emojiCode == null) return;
    if (reactions == null) {
      reactions = {};
    }
    final oldReactions = Map<String, dynamic>.from(reactions);
    // If user has already reacted to this message then
    // we just remove him from reacted users only to readd him
    // with a different Emoji
    final previousEmoji = _userReactedWith(emojiCode, userId);
    if (previousEmoji != null) {
      List users = reactions[previousEmoji]['users'];
      reactions[previousEmoji]['count']--;
      users.remove(userId);
      if (users.isEmpty) {
        reactions.remove(previousEmoji);
      }
    }
    // In case if someone already reacted with this emoji, keep working with it
    if (reactions[emojiCode] != null) {
      // Get the list of people, who reacted with this emoji
      List users = reactions[emojiCode]['users'];
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
        emojiCode = '';
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
    // TODO sync with api
    // _api
    //     .reactionSend(
    //   this.channelId,
    //   this.id,
    //   emojiCode,
    //   threadId: threadId,
    // )
    //     .catchError((_) {
    //   reactions = oldReactions;
    //   if (reactions.isEmpty) {
    //     reactions = null;
    //   }
    // });
  }

  // Helper method to check, if the user has already reacted with different emoji
  String _userReactedWith(String emojiCode, String userId) {
    bool reacted = false;
    String _emojiCode;
    final emojis = reactions.keys;
    for (int i = 0; i < emojis.length; i++) {
      final users = reactions[emojis.elementAt(i)]['users'] as List;
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
