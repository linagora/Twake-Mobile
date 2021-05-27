// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    id: json['id'] as String,
    threadId: json['thread_id'] as String?,
    channelId: json['channel_id'] as String,
    userId: json['user_id'] as String,
    creationDate: json['creation_date'] as int,
    modificationDate: json['modification_date'] as int,
    responsesCount: json['responses_count'] as int,
    username: json['username'] as String,
    content: MessageContent.fromJson(json['content'] as Map<String, dynamic>),
    reactions: (json['reactions'] as List<dynamic>)
        .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
        .toList(),
    firstname: json['firstname'] as String?,
    lastname: json['lastname'] as String?,
    thumbnail: json['thumbnail'] as String?,
    draft: json['draft'] as String?,
  )..isRead = json['is_read'] as bool;
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'thread_id': instance.threadId,
      'channel_id': instance.channelId,
      'user_id': instance.userId,
      'creation_date': instance.creationDate,
      'modification_date': instance.modificationDate,
      'responses_count': instance.responsesCount,
      'content': instance.content.toJson(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'username': instance.username,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'thumbnail': instance.thumbnail,
      'draft': instance.draft,
      'is_read': instance.isRead,
    };
