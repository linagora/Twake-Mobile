import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';

part 'cache_file_state.dart';

class CacheFileCubit extends Cubit<CacheFileState> {
  CacheFileCubit() : super(CacheFileState(fileList: []));

  void cacheFile({required File file}) async {
    List<File> cachedList = [...state.fileList];
    final cachedFile = state.fileList.firstWhereOrNull((cacheFile) => cacheFile.id == file.id);
    if(cachedFile == null) {
      cachedList.add(file);
    }
    emit(CacheFileState(fileList: cachedList));
  }

  File? findCachedFile({required String fileId}) {
    return state.fileList.firstWhereOrNull((file) => file.id == fileId);
  }

  void cleanCachedFiles() async {
    emit(CacheFileState(fileList: []));
  }
}
