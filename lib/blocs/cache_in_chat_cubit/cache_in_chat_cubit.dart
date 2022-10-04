import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_state.dart';
import 'package:twake/models/file/file.dart';

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
}
