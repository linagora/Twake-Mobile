import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pinned_info.g.dart';

@JsonSerializable()
class PinnedInfo extends Equatable {
  @JsonKey(name: 'pinned_by')
  final String pinnedBy;
  @JsonKey(name: 'pinned_at')
  final int pinnedAt;

  PinnedInfo({
    required this.pinnedBy,
    required this.pinnedAt,
  });

  factory PinnedInfo.fromJson(Map<String, dynamic> json) =>
      _$PinnedInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PinnedInfoToJson(this);

  @override
  List<Object?> get props => [pinnedBy, pinnedAt];
}
