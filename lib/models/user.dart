import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/collection_item.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends CollectionItem {
  @JsonKey(required: true)
  final String id;
  final String username;
  @JsonKey(name: 'firstname')
  String firstName;
  @JsonKey(name: 'lastname')
  String lastName;
  String thumbnail;

  User({this.id, this.username});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
