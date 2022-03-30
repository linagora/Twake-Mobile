import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_state.dart';
import 'package:twake/models/file/file.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

class CacheInChatCubit extends Cubit<CacheInChatState> {
  CacheInChatCubit() : super(CacheInChatState());

  void cacheFile({required File file}) async {
    List<File> cachedList = [...state.fileList];
    final cachedFile = state.fileList.firstWhereOrNull((cacheFile) => cacheFile.id == file.id);
    if(cachedFile == null) {
      cachedList.add(file);
    }
    emit(CacheInChatState(fileList: cachedList));
  }

  File? findCachedFile({required String fileId}) {
    return state.fileList.firstWhereOrNull((file) => file.id == fileId);
  }

  void cleanCachedFiles() async {
    emit(CacheInChatState(fileList: []));
  }

  void cacheUrlPreviewData({required String url, required PreviewData previewData}) async {
    Map<String, PreviewData> cachedData = Map.of(state.previewDataMap);
    final cachedUrl = state.previewDataMap[url];
    if(cachedUrl == null) {
      cachedData[url] = previewData;
    }
    emit(state.copyWith(newDataMap: cachedData));
  }

  PreviewData? findCachedPreviewData({required String url}) {
    return state.previewDataMap[url];
  }

  void cleanCachedPreviewData() async {
    emit(state.copyWith(newDataMap: {}));
  }
}
