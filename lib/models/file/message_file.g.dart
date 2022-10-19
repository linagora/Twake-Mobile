// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageFile _$MessageFileFromJson(Map<String, dynamic> json) => MessageFile(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      createdAt: json['created_at'] as int,
      metadata: MessageFileMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      context: json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageFileToJson(MessageFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'created_at': instance.createdAt,
      'metadata': instance.metadata,
      'user': instance.user,
      'context': instance.context,
    };
