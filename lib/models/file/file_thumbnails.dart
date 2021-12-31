import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_thumbnails.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FileThumbnails extends Equatable {
  final String id;
  final int index;
  final int size;
  final String type;
  final int width;
  final int height;
  final String url;

  FileThumbnails({
    required this.id,
    required this.index,
    required this.size,
    required this.type,
    required this.width,
    required this.height,
    required this.url,
  });

  factory FileThumbnails.fromJson(Map<String, dynamic> json) =>
      _$FileThumbnailsFromJson(json);


  Map<String, dynamic> toJson() => _$FileThumbnailsToJson(this);

  @override
  List<Object> get props => [id, index, size, type, width, height, url];
}
