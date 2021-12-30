import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/attachment/attachment.dart';
import 'package:twake/models/attachment/attachment_metadata.dart';
import 'package:twake/models/attachment/external_id.dart';
import 'package:twake/models/file/file_metadata.dart';
import 'package:twake/models/file/file_thumbnails.dart';
import 'package:twake/models/file/file_upload_data.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

part 'file.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class File extends Equatable {
  final String id;
  final String companyId;
  final String userId;
  final FileMetadata metadata;
  final List<FileThumbnails> thumbnails;
  final FileUploadData uploadData;
  final int createdAt;
  final int updatedAt;

  File({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.metadata,
    required this.thumbnails,
    required this.uploadData,
    required this.createdAt,
    required this.updatedAt
  });

  factory File.fromJson(Map<String, dynamic> json) => _$FileFromJson(json);

  Map<String, dynamic> toJson() => _$FileToJson(this);

  @override
  List<Object?> get props => [
    id,
    companyId,
    userId,
    metadata,
    thumbnails,
    uploadData,
    createdAt,
    updatedAt
  ];
}

extension FileExtenstion on File {
  String get thumbnailUrl {
    if(thumbnails.isEmpty) {
      return '';
    }
    return sprintf(Endpoint.downloadFileThumbnail,
      [Globals.instance.host, Globals.instance.companyId, this.id, this.thumbnails.last.id]);
  }

  String get downloadUrl => sprintf(Endpoint.downloadFile,
      [Globals.instance.host, Globals.instance.companyId, this.id]);

  Attachment toAttachment() => Attachment(
      id: id,
      companyId: companyId,
      metadata: AttachmentMetadata(
        source: Source.internal,
        externalId: ExternalId(id: id, companyId: companyId),
        name: metadata.name,
        mime: metadata.mime,
        thumbnailsStatus: metadata.thumbnailsStatus,
        size: uploadData.size,
        thumbnails: thumbnails,
      ),
    );
}
