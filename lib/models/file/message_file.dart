import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:twake/models/attachment/attachment.dart';
import 'package:twake/models/attachment/attachment_metadata.dart';
import 'package:twake/models/attachment/external_id.dart';
import 'package:twake/models/file/context.dart';
import 'package:twake/models/file/message_file_metadata.dart';
import 'package:twake/models/file/user.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/api_data_transformer.dart';

part 'message_file.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageFile extends Equatable {
  final String id;
  final String companyId;
  final int createdAt;
  final MessageFileMetadata metadata;
  final User? user;
  final Context context;

  MessageFile(
      {required this.id,
      required this.companyId,
      required this.createdAt,
      required this.metadata,
      this.user,
      required this.context});

  factory MessageFile.fromJson(Map<String, dynamic> json) {
    return _$MessageFileFromJson(ApiDataTransformer.messageFile(json: json));
  }

  Map<String, dynamic> toJson() => _$MessageFileToJson(this);

  @override
  List<Object?> get props =>
      [id, companyId, createdAt, metadata, user, context];
}

extension MessageFileExtenstion on MessageFile {
  String get thumbnailUrl {
    if (this.metadata.thumbnailId.isEmpty) {
      return '';
    }

    return sprintf(Endpoint.downloadFileThumbnail, [
      Globals.instance.host,
      Globals.instance.companyId,
      this.metadata.externalId,
      this.metadata.thumbnailId
    ]);
  }

  String get downloadUrl => sprintf(Endpoint.downloadFile, [
        Globals.instance.host,
        Globals.instance.companyId,
        this.metadata.externalId,
      ]);

  Attachment toAttachment() => Attachment(
        id: id,
        companyId: companyId,
        metadata: AttachmentMetadata(
          source: Source.internal,
          externalId:
              ExternalId(id: this.metadata.externalId, companyId: companyId),
          name: metadata.name,
          mime: metadata.mime,
          thumbnailsStatus:
              metadata.thumbnailsStatus ?? ThumbnailStatus.waiting,
          size: this.metadata.size,
          thumbnails: this.metadata.thumbnails,
        ),
      );
}
