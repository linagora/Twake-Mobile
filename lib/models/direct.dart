import 'package:json_annotation/json_annotation.dart';
// import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/collection_item.dart';
// import 'package:twake/widgets/common/image_avatar.dart';

part 'direct.g.dart';

@JsonSerializable(explicitToJson: true)
class Direct extends CollectionItem {
  @JsonKey(required: true)
  final String id;

  String name;

  @JsonKey(required: true, name: 'company_id')
  final String companyId;

  @JsonKey(required: true)
  List<String> members;

  String icon;

  String description;

  @JsonKey(required: true, name: 'members_count')
  int membersCount;

  @JsonKey(required: true, name: 'private')
  bool isPrivate;

  @JsonKey(required: true, name: 'last_activity')
  int lastActivity;

  @JsonKey(required: true, name: 'messages_total')
  int messageTotal;

  @JsonKey(required: true, name: 'messages_unread')
  int messageUnread;

  // List<DirectMember> getCorrespondents(profile) {
  // final correspondents = members.where((m) {
  // return !profile.isMe(m.userId);
  // }).toList();
  // return correspondents;
  // }

  // List<Widget> buildCorrespondentAvatars(profile) {
  // final correspondents = getCorrespondents(profile);
  // List<Padding> paddedAvatars = [];
  // for (int i = 0; i < correspondents.length; i++) {
  // paddedAvatars.add(Padding(
  // padding: EdgeInsets.only(left: i * Dim.wm2),
  // child: ImageAvatar(correspondents[i].thumbnail)));
  // }
  // return paddedAvatars;
  // }

  // String buildDirectName(profile) {
  // if (this.name.isNotEmpty) return this.name;
//
  // final correspondents = getCorrespondents(profile);
  // if (correspondents.length == 1) {
  // return '${correspondents[0].firstName} ${correspondents[0].lastName}';
  // }
  // String name =
  // '${correspondents[0].firstName} ${correspondents[0].lastName}';
  // for (int i = 1; i < correspondents.length; i++) {
  // name += ', ${correspondents[i].firstName} ${correspondents[i].lastName}';
  // }
  // return name;
  // }

  Direct({
    this.id,
    this.companyId,
  });

  factory Direct.fromJson(Map<String, dynamic> json) => _$DirectFromJson(json);

  Map<String, dynamic> toJson() => _$DirectToJson(this);
}
