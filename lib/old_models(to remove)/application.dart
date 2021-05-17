import 'package:json_annotation/json_annotation.dart';

part 'application.g.dart';

@JsonSerializable()
class Application {
  @JsonKey(required: true)
  final String id;
  @JsonKey(defaultValue: 'Unknown Bot')
  String name;
  @JsonKey(name: 'icon_url')
  String iconUrl;
  String description;
  String website;

  Application({this.id, this.name});

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}
