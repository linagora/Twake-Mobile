import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';

class CacheInChatState extends Equatable {
  final List<File> fileList;

  const CacheInChatState({
    this.fileList = const [],
  });

  CacheInChatState copyWith({
    List<File>? newFileList,
  }) {
    return CacheInChatState(
      fileList: newFileList ?? this.fileList,
    );
  }

  @override
  List<Object> get props => [fileList];
}
