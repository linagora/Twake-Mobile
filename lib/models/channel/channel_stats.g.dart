// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelStats _$ChannelStatsFromJson(Map<String, dynamic> json) => ChannelStats(
      members: json['members'] as int,
      messages: json['messages'] as int,
    );

Map<String, dynamic> _$ChannelStatsToJson(ChannelStats instance) =>
    <String, dynamic>{
      'members': instance.members,
      'messages': instance.messages,
    };
