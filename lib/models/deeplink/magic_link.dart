import 'package:equatable/equatable.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'magic_link.g.dart';

@JsonSerializable()
class MagicLink extends BaseModel with EquatableMixin {

  final String? link;

  const MagicLink(this.link);

  const MagicLink.init() : this('');

  factory MagicLink.fromJson(Map<String, dynamic> json) => _$MagicLinkFromJson(json);

  @override
  Map<String, dynamic> toJson({bool stringify = true}) => _$MagicLinkToJson(this);

  @override
  List<Object?> get props => [link];

}