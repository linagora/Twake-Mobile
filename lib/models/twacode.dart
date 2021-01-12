import 'package:json_annotation/json_annotation.dart';

part 'twacode.g.dart';

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
