import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_upload_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FileUploadData extends Equatable {
  final int size;
  final int chunks;

  FileUploadData({
    required this.size,
    required this.chunks
  });

  factory FileUploadData.fromJson(Map<String, dynamic> json) =>
      _$FileUploadDataFromJson(json);


  Map<String, dynamic> toJson() => _$FileUploadDataToJson(this);

  @override
  List<Object> get props => [size, chunks];
}
