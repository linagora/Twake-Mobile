import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_metadata.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FileMetadata extends Equatable {
  final String name;
  final String mime;
  final ThumbnailStatus thumbnailsStatus;

  FileMetadata({
    required this.name,
    required this.mime,
    required this.thumbnailsStatus,
  });

  factory FileMetadata.fromJson(Map<String, dynamic> json) =>
      _$FileMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$FileMetadataToJson(this);

  @override
  List<Object> get props => [name, mime, thumbnailsStatus];
}

enum ThumbnailStatus {
  @JsonValue('done')
  done,
  @JsonValue('waiting')
  waiting
}