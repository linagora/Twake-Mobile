import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/attachment/attachment_metadata.dart';
import 'package:twake/models/file/file_thumbnails.dart';

part 'message_file_metadata.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageFileMetadata extends Equatable {
  final String name;
  final String mime;
  @JsonKey(name: 'external_id')
  final String externalId;
  final ThumbnailStatus? thumbnailsStatus;
  final int size;
  final List<FileThumbnails> thumbnails;

  MessageFileMetadata(
      {required this.name,
      required this.mime,
      required this.externalId,
      this.thumbnailsStatus,
      required this.size,
      required this.thumbnails});

  factory MessageFileMetadata.fromJson(Map<String, dynamic> json) {
    return _$MessageFileMetadataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MessageFileMetadataToJson(this);

  @override
  List<Object> get props =>
      [name, mime, externalId, size, thumbnails];
}

extension MessageFileMetadataExtenstion on MessageFileMetadata {
  String get thumbnailId {
    if (thumbnails.isEmpty) {
      return '';
    }
    return this.thumbnails.last.id;
  }
}
