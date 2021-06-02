import 'package:json_annotation/json_annotation.dart';

part 'badge.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Badge {
  final String type;
  final String id;
  final int count;

  const Badge({
    required this.type,
    required this.id,
    required this.count,
  });

  factory Badge.fromJson({required Map<String, dynamic> json}) {
    return _$BadgeFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$BadgeToJson(this);
  }
}
