// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twacode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageTwacode _$MessageTwacodeFromJson(Map<String, dynamic> json) {
  return MessageTwacode(
    originalStr: json['original_str'] as String,
    prepared: json['prepared'] as List,
  );
}

Map<String, dynamic> _$MessageTwacodeToJson(MessageTwacode instance) =>
    <String, dynamic>{
      'original_str': instance.originalStr,
      'prepared': instance.prepared,
    };
