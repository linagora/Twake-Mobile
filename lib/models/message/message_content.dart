import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageContent {
  final String? originalStr;
  final List<dynamic> prepared;

  const MessageContent({
    this.originalStr,
    required this.prepared,
  });
}
