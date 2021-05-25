import 'package:json_annotation/json_annotation.dart';

part 'reaction.g.dart';

@JsonSerializable()
class Reaction {
  final String name;
  final List<String> users;
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
