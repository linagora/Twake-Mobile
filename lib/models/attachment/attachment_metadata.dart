import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/attachment/external_id.dart';
import 'package:twake/models/file/file_thumbnails.dart';

part 'attachment_metadata.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachmentMetadata extends Equatable {
  final Source source;
  final ExternalId externalId;
  final String name;
  final String mime;
  final int size;
  final List<FileThumbnails> thumbnails;
  final ThumbnailStatus thumbnailsStatus;

  AttachmentMetadata({
    required this.source,
    required this.externalId,
    required this.name,
    required this.mime,
    required this.size,
    required this.thumbnails,
    required this.thumbnailsStatus,
  });

  factory AttachmentMetadata.fromJson(Map<String, dynamic> json) =>
      _$AttachmentMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentMetadataToJson(this);

  @override
  List<Object> get props => [
    source,
    externalId,
    name,
    mime,
    size,
    thumbnails,
    thumbnailsStatus,
  ];
}

enum ThumbnailStatus {
  @JsonValue('done')
  done,
  @JsonValue('waiting')
  waiting
}

enum Source {
  @JsonValue('internal')
  internal,
  @JsonValue('drive')
  drive
}