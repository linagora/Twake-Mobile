import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/file/file.dart';

part 'cache_files_state.dart';

class CacheFilesCubit extends Cubit<CacheFilesState> {
  CacheFilesCubit() : super(CacheFilesInitial(fileList: []));
  List<File> fileList = [];

  void setFile({required File file}) async {
    fileList.firstWhereOrNull((cacheFile) => cacheFile.id == file.id) == null
        ? fileList.add(file)
        : null;
  }

  void findCacheFile({required String fileId}) async {
    final cacheFile = fileList.firstWhereOrNull((file) => file.id == fileId);
    cacheFile == null
        ? emit(CacheFileNotFoun())
        : emit(CacheFileFound(cacheFile: cacheFile));
  }

  void cleanCacheFiles({required File file}) async {
    fileList = [];

    emit(CacheFilesInitial(fileList: fileList));
  }
}
