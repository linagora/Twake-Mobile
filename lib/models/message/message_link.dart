import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/base_model/base_model.dart';

part 'message_link.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MessageLink extends BaseModel {

  final String? title;
  final String? domain;
  final String? description;

  final String? favicon;
  final String? img;
  final double? imageHeight;
  final double? imageWidth;
  final String url;

  MessageLink(
    this.url,
    this.title,
    this.domain,
    this.description,
    this.favicon,
    this.img,
    this.imageHeight,
    this.imageWidth,
  );

  @override
  Map<String, dynamic> toJson({bool stringify = true}) {
    return _$MessageLinkToJson(this);
  }

  factory MessageLink.fromJson(Map<String, dynamic> json) => _$MessageLinkFromJson(json);

}