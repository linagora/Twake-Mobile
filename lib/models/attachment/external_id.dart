import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_id.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExternalId extends Equatable {
  final String id;
  final String companyId;

  ExternalId({
    required this.id,
    required this.companyId,
  });

  factory ExternalId.fromJson(Map<String, dynamic> json) =>
      _$ExternalIdFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalIdToJson(this);

  @override
  List<Object> get props => [id, companyId];
}
