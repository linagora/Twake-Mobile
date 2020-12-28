// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'sender',
    'creation_date',
    'content',
    'channelId'
  ]);
  return Message(
    id: json['id'] as String,
    sender: (json['sender'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    creationDate: json['creation_date'] as int,
  )
    ..threadId = json['thread_id'] as String
    ..responsesCount = json['responses_count'] as int ?? 0
    ..content = json['content'] == null
        ? null
        : MessageTwacode.fromJson(json['content'] as Map<String, dynamic>)
    ..reactions = json['reactions'] as Map<String, dynamic> ?? {}
    ..channelId = json['channelId'] as String
    ..isSelected = json['isSelected'] as bool ?? false;
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'thread_id': instance.threadId,
      'responses_count': instance.responsesCount,
      'sender': instance.sender,
      'creation_date': instance.creationDate,
      'content': instance.content?.toJson(),
      'reactions': instance.reactions,
      'channelId': instance.channelId,
      'isSelected': instance.isSelected,
    };
