import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/data/local/type_constants.dart';

part 'message_summary.g.dart';

@HiveType(typeId: TypeConstant.MESSAGE_SUMMARY)
@JsonSerializable(fieldRename: FieldRename.snake)
class MessageSummary extends HiveObject {
  @HiveField(0)
  final int date;

  @HiveField(1, defaultValue: '0')
  @JsonKey(defaultValue: '0')
  final String sender;

  @HiveField(2, defaultValue: 'Guest')
  @JsonKey(defaultValue: 'Guest')
  final String senderName;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? text;

  static final _userMentionRegex = RegExp('@([a-zA-z0-9._-]+):([a-zA-z0-9-]+)');

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
