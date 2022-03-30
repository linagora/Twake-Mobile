// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PinnedInfo _$PinnedInfoFromJson(Map<String, dynamic> json) {
  return PinnedInfo(
    pinnedBy: json['pinned_by'] as String,
    pinnedAt: json['pinned_at'] as int,
  );
}

Map<String, dynamic> _$PinnedInfoToJson(PinnedInfo instance) =>
    <String, dynamic>{
      'pinned_by': instance.pinnedBy,
      'pinned_at': instance.pinnedAt,
    };
