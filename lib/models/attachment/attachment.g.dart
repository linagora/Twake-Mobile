// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return Attachment(
    id: json['id'] as String,
    companyId: json['company_id'] as String,
    metadata:
        AttachmentMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    messageId: json['message_id'] as String?,
  );
}

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'message_id': instance.messageId,
      'metadata': instance.metadata,
    };
