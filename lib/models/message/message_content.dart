import 'package:json_annotation/json_annotation.dart';

part 'message_content.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageContent {
  final String? originalStr;
  final List<dynamic> prepared;

  const MessageContent({
    this.originalStr,
    required this.prepared,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentToJson(this);
}
