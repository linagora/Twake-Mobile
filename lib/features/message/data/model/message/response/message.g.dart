// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      channelId: json['channel_id'] as String? ?? '',
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
      files: json['files'] as List<dynamic>?,
      delivery: $enumDecodeNullable(_$DeliveryEnumMap, json['delivery']) ??
          Delivery.delivered,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      picture: json['picture'] as String?,
      draft: json['draft'] as String?,
      quoteMessage: json['quote_message'] == null
          ? null
          : Message.fromJson(json['quote_message'] as Map<String, dynamic>),
      subtype: $enumDecodeNullable(_$MessageSubtypeEnumMap, json['subtype']),
      pinnedInfo: json['pinned_info'] == null
          ? null
          : PinnedInfo.fromJson(json['pinned_info'] as Map<String, dynamic>),
      links: (json['links'] as List<dynamic>?)
              ?.map((e) => MessageLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MessageLink>[],
    )..lastReplies1 = (json['last_replies'] as List<dynamic>?)
            ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

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
      'files': instance.files,
      'subtype': _$MessageSubtypeEnumMap[instance.subtype],
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'pinned_info': instance.pinnedInfo?.toJson(),
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'picture': instance.picture,
      'draft': instance.draft,
      'delivery': _$DeliveryEnumMap[instance.delivery],
      'last_replies': instance.lastReplies1?.map((e) => e.toJson()).toList(),
      'quote_message': instance.quoteMessage?.toJson(),
      'links': instance.links?.map((e) => e.toJson()).toList(),
    };

const _$DeliveryEnumMap = {
  Delivery.inProgress: 'in_progress',
  Delivery.delivered: 'delivered',
  Delivery.failed: 'failed',
};

const _$MessageSubtypeEnumMap = {
  MessageSubtype.application: 'application',
  MessageSubtype.deleted: 'deleted',
  MessageSubtype.system: 'system',
};
