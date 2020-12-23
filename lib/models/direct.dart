import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/common/image_avatar.dart';

part 'direct.g.dart';

@JsonSerializable(explicitToJson: true)
class Direct {
  @JsonKey(required: true)
  final String id;

  final String name;

  @JsonKey(required: true)
  final List<DirectMember> members;

  final String icon;

  final String description;

  @JsonKey(required: true, name: 'members_count')
  final int membersCount;

  @JsonKey(required: true, name: 'private')
  final bool isPrivate;

  @JsonKey(required: true, name: 'last_activity')
  final int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  final int messageTotal;

  @JsonKey(required: true, name: 'messages_unread')
  final int messageUnread;

  List<DirectMember> getCorrespondents(profile) {
    final correspondents = members.where((m) {
      return !profile.isMe(m.userId);
    }).toList();
    return correspondents;
  }

  List<Widget> buildCorrespondentAvatars(profile) {
    final correspondents = getCorrespondents(profile);
    List<Padding> paddedAvatars = [];
    for (int i = 0; i < correspondents.length; i++) {
      paddedAvatars.add(Padding(
          padding: EdgeInsets.only(left: i * Dim.wm2),
          child: ImageAvatar(correspondents[i].thumbnail)));
    }
    return paddedAvatars;
  }

  String buildDirectName(profile) {
    if (this.name.isNotEmpty) return this.name;

    final correspondents = getCorrespondents(profile);
    if (correspondents.length == 1) {
      return '${correspondents[0].firstName} ${correspondents[0].lastName}';
    }
    String name =
        '${correspondents[0].firstName} ${correspondents[0].lastName}';
    for (int i = 1; i < correspondents.length; i++) {
      name += ', ${correspondents[i].firstName} ${correspondents[i].lastName}';
    }
    return name;
  }

  Direct({
    @required this.id,
    this.name,
    this.icon,
    this.description,
    @required this.membersCount,
    @required this.isPrivate,
    @required this.lastActivity,
    @required this.messageTotal,
    @required this.members,
    @required this.messageUnread,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// workspaceId is saved on per channel basis in order to save and retrieve
  /// channels from data store later.
  factory Direct.fromJson(Map<String, dynamic> json) => _$DirectFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$DirectToJson(this);
    return map;
  }
}

@JsonSerializable()
class DirectMember {
  @JsonKey(required: true)
  final String userId;

  @JsonKey(required: true)
  final String username;

  @JsonKey(name: 'firstname')
  final String firstName;

  @JsonKey(name: 'lastname')
  final String lastName;

  final String thumbnail;

  // final int timeZoneOffset;

  DirectMember({
    @required this.userId,
    @required this.username,
    this.firstName,
    this.lastName,
    this.thumbnail,
    // this.timeZoneOffset,
  });

  /// Convenience methods to avoid deserializing this class from JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  /// workspaceId is saved on per channel basis in order to save and retrieve
  /// channels from data store later.
  factory DirectMember.fromJson(Map<String, dynamic> json) =>
      _$DirectMemberFromJson(json);

  /// Convenience methods to avoid serializing this class to JSON
  /// https://flutter.dev/docs/development/data-and-backend/json#code-generation
  Map<String, dynamic> toJson() {
    var map = _$DirectMemberToJson(this);
    return map;
  }
}
