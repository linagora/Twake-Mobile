// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageSummary _$MessageSummaryFromJson(Map<String, dynamic> json) {
  return MessageSummary(
    date: json['date'] as int,
    sender: json['sender'] as String,
    senderName: json['sender_name'] as String,
    title: json['title'] as String,
    text: json['text'] as String?,
  );
}

Map<String, dynamic> _$MessageSummaryToJson(MessageSummary instance) =>
    <String, dynamic>{
      'date': instance.date,
      'sender': instance.sender,
      'sender_name': instance.senderName,
      'title': instance.title,
      'text': instance.text,
    };
