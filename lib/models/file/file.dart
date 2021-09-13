import 'package:json_annotation/json_annotation.dart';
import 'package:twake/utils/api_data_transformer.dart';

part 'file.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class File {
  final String id;
  final String name;
  final String companyId;
  final String? preview;
  final int size;

  const File({
    required this.id,
    required this.name,
    required this.companyId,
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

  String get download =>
      '/companies/$companyId/files/$id/download'; // TODO implement download link generation

  String get sizeStr {
    const MB = 1024 * 1024;
    const KB = 1024;
    return size > MB
        ? '${(size / MB).toStringAsFixed(2)} MB'
        : size > KB
            ? '${(size / KB).toStringAsFixed(2)} KB'
            : '$size B';
  }

  factory File.fromJson({
    required Map<String, dynamic> json,
    bool transform: false,
  }) {
    if (transform) json = ApiDataTransformer.file(json: json);

    return _$FileFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FileToJson(this);
}
