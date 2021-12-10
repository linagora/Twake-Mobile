import 'package:equatable/equatable.dart';

class FileUploadingOption extends Equatable {
  final int? thumbnailSync;
  final String? fileName;
  final String? type;
  final int? totalSize;

  FileUploadingOption(
      {this.thumbnailSync, this.fileName, this.type, this.totalSize});

  @override
  List<Object?> get props => [thumbnailSync, fileName, type, totalSize];
}
