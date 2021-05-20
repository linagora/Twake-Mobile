import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/channel/channel_visibility.dart';
import 'package:twake/utils/json.dart' as jsn;

part 'channel.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Channel extends BaseModel {
  static const COMPOSITE_FIELDS = ['members', 'visibility', 'permissions'];

  final String id;

  final String name;

  final String? icon;

  final String? description;

  final String companyId;

  final String workspaceId;

  final int membersCount;

  final List<String> members;

  final ChannelVisibility visibility;

  final int lastActivity;

  final int userLastAccess;

  final String? draft;

  List<String> permissions;

  bool get hasUnread => userLastAccess < lastActivity;

  Channel(
      {required this.id,
      required this.name,
      this.icon,
      this.description,
      required this.companyId,
      required this.workspaceId,
      required this.membersCount,
      required this.members,
      required this.visibility,
      required this.lastActivity,
      required this.userLastAccess,
      this.draft,
      required this.permissions});

  factory Channel.fromJson({
    required Map<String, dynamic> json,
    bool jsonify: true,
  }) {
    // message retrieved from sqlite database will have
    // it's composite fields json string encoded, so there's a
    // need to decode them back
    if (jsonify) {
      json = jsn.jsonify(json: json, keys: COMPOSITE_FIELDS);
    }
    return _$ChannelFromJson(json);
  }

  @override
  Map<String, dynamic> toJson({stringify: true}) {
    var json = _$ChannelToJson(this);
    // message that is to be stored to sqlite database should have
    // it's composite fields json string encoded, because sqlite doesn't support
    // non primitive data types, so we need to encode those fields
    if (stringify) {
      json = jsn.stringify(json: json, keys: COMPOSITE_FIELDS);
    }
    return json;
  }
}
