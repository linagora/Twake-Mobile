import 'package:json_annotation/json_annotation.dart';

part 'message_summary.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageSummary {
  final int date;
  final String sender;
  final String senderName;
  final String title;
  final String? text;

  const MessageSummary({
    required this.date,
    required this.sender,
    required this.senderName,
    required this.title,
    this.text,
  });

  factory MessageSummary.fromJson(Map<String, dynamic> json) {
    return _$MessageSummaryFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MessageSummaryToJson(this);
  }
}
