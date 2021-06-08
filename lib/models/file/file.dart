import 'package:json_annotation/json_annotation.dart';

part 'file.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class File {
  final String id;
  final String name;
  final String? preview;
  final String download;
  final String size;

  const File({
    required this.id,
    required this.name,
    required this.download,
    required this.size,
    this.preview,
  });

  Map<String, Object?> toMap() {
    return {
      "type": "file",
      "mode": "preview",
      "content": id,
      "metadata": {
        "size": size,
        "name": name,
        "preview": preview,
        "download": download
      }
    };
  }

  factory File.fromJson({required Map<String, dynamic> json}) =>
      _$FileFromJson(json);

  Map<String, dynamic> toJson() => _$FileToJson(this);
}
