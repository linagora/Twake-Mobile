import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel_stats.g.dart';

@JsonSerializable()
class ChannelStats extends Equatable {

  final int members;
  final int messages;

  ChannelStats({required this.members, required this.messages});

  factory ChannelStats.fromJson(Map<String, dynamic> json) =>
      _$ChannelStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelStatsToJson(this);


  @override
  List<Object?> get props => [members, messages];

}