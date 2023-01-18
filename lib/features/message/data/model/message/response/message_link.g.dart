// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageLink _$MessageLinkFromJson(Map<String, dynamic> json) => MessageLink(
      json['url'] as String,
      json['title'] as String?,
      json['domain'] as String?,
      json['description'] as String?,
      json['favicon'] as String?,
      json['img'] as String?,
      (json['image_height'] as num?)?.toDouble(),
      (json['image_width'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MessageLinkToJson(MessageLink instance) =>
    <String, dynamic>{
      'title': instance.title,
      'domain': instance.domain,
      'description': instance.description,
      'favicon': instance.favicon,
      'img': instance.img,
      'image_height': instance.imageHeight,
      'image_width': instance.imageWidth,
      'url': instance.url,
    };
