import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/attachment/attachment_metadata.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/file_metadata.dart';
import 'package:twake/models/file/file_upload_data.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

part 'attachment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Attachment extends Equatable {
  final String id;
  final String companyId;
  final String? messageId;
  final AttachmentMetadata metadata;

  Attachment({
    required this.id,
    required this.companyId,
    required this.metadata,
    this.messageId,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @override
  List<Object?> get props => [
    id,
    messageId,
    companyId,
    metadata
  ];
}

extension AttachmentExtenstion on Attachment {
  String get thumbnailUrl {
    if(metadata.thumbnails.isEmpty) {
      return '';
    }
    return sprintf(Endpoint.downloadFileThumbnail,
        [Globals.instance.host, Globals.instance.companyId, this.id, metadata.thumbnails.last.id]);
  }

  String get downloadUrl => sprintf(Endpoint.downloadFile,
      [Globals.instance.host, Globals.instance.companyId, this.id]);

  File toFile({required String userId, required int createdAt, required int updatedAt}) {
    return File(
        id: metadata.externalId.id,
        companyId: companyId,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        metadata: FileMetadata(
            name: metadata.name, mime: metadata.mime, thumbnailsStatus: metadata.thumbnailsStatus),
        thumbnails: metadata.thumbnails,
        uploadData: FileUploadData(size: metadata.size, chunks: 1));
  }
}
