import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'reaction.g.dart';

@HiveType(typeId: TypeConstant.MESSAGE_REACTION)
@JsonSerializable()
class Reaction {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<String> users;

  @HiveField(2)
  int count;

  Reaction({
    required this.name,
    required this.users,
    required this.count,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionToJson(this);
}
