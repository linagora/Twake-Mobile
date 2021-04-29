import 'package:json_annotation/json_annotation.dart';

part 'uploaded_file.g.dart';

@JsonSerializable()
class UploadedFile {
  final String id;

  @JsonKey(name: 'name')
  final String filename;

  final String preview;

  final String download;

  final int size;

  const UploadedFile({
    this.id,
    this.filename,
    this.preview,
    this.download,
    this.size,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) =>
      _$UploadedFileFromJson(json);

  Map<String, dynamic> toJson() => _$UploadedFileToJson(this);
}
