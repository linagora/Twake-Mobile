import 'package:json_annotation/json_annotation.dart';
import 'package:twake/utils/api_data_transformer.dart';

part 'file.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class File {
  final String id;
  final String name;
  final String? preview;
  final String size;

  const File({
    required this.id,
    required this.name,
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

  String get download => ''; // TODO implement download link generation

  factory File.fromJson({
    required Map<String, dynamic> json,
    bool transform: false,
  }) {
    if (transform) json = ApiDataTransformer.file(json: json);

    return _$FileFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FileToJson(this);
}
