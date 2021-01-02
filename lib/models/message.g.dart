// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['id', 'creation_date', 'content', 'channel_id']);
  return Message(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    appId: json['app_id'] as String,
    creationDate: json['creation_date'] as int,
  )
    ..threadId = json['thread_id'] as String
    ..responsesCount = json['responses_count'] as int ?? 0
    ..content = json['content'] == null
        ? null
        : MessageTwacode.fromJson(json['content'] as Map<String, dynamic>)
    ..reactions = json['reactions'] as Map<String, dynamic> ?? {}
    ..channelId = json['channel_id'] as String
    ..isSelected = json['is_selected'] as int ?? 0;
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'thread_id': instance.threadId,
      'responses_count': instance.responsesCount,
      'user_id': instance.userId,
      'app_id': instance.appId,
      'creation_date': instance.creationDate,
      'content': instance.content?.toJson(),
      'reactions': instance.reactions,
      'channel_id': instance.channelId,
      'is_selected': instance.isSelected,
    };
