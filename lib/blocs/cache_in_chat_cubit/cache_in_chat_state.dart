import 'package:equatable/equatable.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:twake/models/file/file.dart';

class CacheInChatState extends Equatable {
  final List<File> fileList;
  final Map<String, PreviewData> previewDataMap;

  const CacheInChatState({
    this.fileList = const [],
    this.previewDataMap = const {},
  });

  CacheInChatState copyWith({
    List<File>? newFileList,
    Map<String, PreviewData>? newDataMap,
  }) {
    return CacheInChatState(
      fileList: newFileList ?? this.fileList,
      previewDataMap: newDataMap ?? this.previewDataMap,
    );
  }

  @override
  List<Object> get props => [fileList, previewDataMap];
}
