import 'package:json_annotation/json_annotation.dart';

part 'message_summary.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageSummary {
  final int date;

  @JsonKey(defaultValue: '0')
  final String sender;

  @JsonKey(defaultValue: 'Guest')
  final String senderName;

  final String title;

  final String? text;

  static final _userMentionRegex = RegExp('@([a-zA-z0-9_]+):([a-zA-z0-9-]+)');

  String? get body {
    return text?.replaceAllMapped(_userMentionRegex, (match) {
      final end = text!.indexOf(':', match.start);
      return text!.substring(match.start, end);
    });
  }

  MessageSummary({
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
