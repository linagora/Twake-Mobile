// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryAdapter extends TypeAdapter<Delivery> {
  @override
  final int typeId = 18;

  @override
  Delivery read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Delivery.inProgress;
      case 1:
        return Delivery.delivered;
      case 2:
        return Delivery.failed;
      default:
        return Delivery.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, Delivery obj) {
    switch (obj) {
      case Delivery.inProgress:
        writer.writeByte(0);
        break;
      case Delivery.delivered:
        writer.writeByte(1);
        break;
      case Delivery.failed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageSubtypeAdapter extends TypeAdapter<MessageSubtype> {
  @override
  final int typeId = 19;

  @override
  MessageSubtype read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageSubtype.application;
      case 1:
        return MessageSubtype.deleted;
      case 2:
        return MessageSubtype.system;
      default:
        return MessageSubtype.application;
    }
  }

  @override
  void write(BinaryWriter writer, MessageSubtype obj) {
    switch (obj) {
      case MessageSubtype.application:
        writer.writeByte(0);
        break;
      case MessageSubtype.deleted:
        writer.writeByte(1);
        break;
      case MessageSubtype.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSubtypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      lastReplies: (json['last_replies'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Message>[],
    )
      ..subtype = $enumDecodeNullable(_$MessageSubtypeEnumMap, json['subtype'])
      ..pinnedInfo = json['pinned_info'] == null
          ? null
          : PinnedInfo.fromJson(json['pinned_info'] as Map<String, dynamic>);

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
      'last_replies': instance.lastReplies?.map((e) => e.toJson()).toList(),
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
