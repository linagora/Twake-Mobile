// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    id: json['id'] as String,
    threadId: json['thread_id'] as String,
    channelId: json['channel_id'] as String,
    userId: json['user_id'] as String,
    createdAt: json['created_at'] as int,
    updatedAt: json['updated_at'] as int,
    responsesCount: json['responses_count'] as int? ?? 0,
    username: json['username'] as String?,
    text: json['text'] as String? ?? '',
    blocks: json['blocks'] as List<dynamic>,
    reactions: (json['reactions'] as List<dynamic>?)
            ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    picture: json['picture'] as String?,
    draft: json['draft'] as String?,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'thread_id': instance.threadId,
      'channel_id': instance.channelId,
      'user_id': instance.userId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'responses_count': instance.responsesCount,
      'text': instance.text,
      'blocks': instance.blocks,
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'picture': instance.picture,
      'draft': instance.draft,
    };
