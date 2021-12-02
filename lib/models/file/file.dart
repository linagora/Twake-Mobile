import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
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

  const File({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.metadata,
    required this.thumbnails,
    required this.uploadData
  });

  Map<String, Object?> toMap() {
    return {
      "type": "file",
      "mode": "preview",
      "content": id,
      "metadata": {
        "size": uploadData.size,
        "name": metadata.name,
      }
    };
  }

  factory File.fromJson({required Map<String, dynamic> json}) => _$FileFromJson(json);

  Map<String, dynamic> toJson() => _$FileToJson(this);

  @override
  List<Object?> get props => [id, companyId, userId, metadata, thumbnails, uploadData];
}

extension FileExtenstion on File {
  String get thumbnailUrl => sprintf(Endpoint.downloadFileThumbnail,
      [Globals.instance.host, Globals.instance.companyId, this.id, this.thumbnails.first.id]);

  String get downloadUrl => sprintf(Endpoint.downloadFile,
      [Globals.instance.host, Globals.instance.companyId, this.id]);

  String get sizeStr {
    const MB = 1024 * 1024;
    const KB = 1024;
    return uploadData.size > MB
        ? '${(uploadData.size / MB).toStringAsFixed(2)} MB'
        : uploadData.size > KB
        ? '${(uploadData.size / KB).toStringAsFixed(2)} KB'
        : '$uploadData.size B';
  }

}
