// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageContent _$MessageContentFromJson(Map<String, dynamic> json) {
  return MessageContent(
    originalStr: json['original_str'] as String?,
    prepared: json['prepared'] as List<dynamic>,
  );
}

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{
      'original_str': instance.originalStr,
      'prepared': instance.prepared,
    };
