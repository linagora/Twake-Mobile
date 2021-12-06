part of 'cache_files_cubit.dart';

abstract class CacheFilesState extends Equatable {
  const CacheFilesState();

  @override
  List<Object> get props => [];
}

class CacheFilesInitial extends CacheFilesState {
  final List<File> fileList;

  const CacheFilesInitial({required this.fileList});

  @override
  List<Object> get props => [fileList];
}

class CacheFileNotFoun extends CacheFilesState {
  const CacheFileNotFoun();
  @override
  List<Object> get props => [];
}

class CacheFileFound extends CacheFilesState {
  final File cacheFile;

  const CacheFileFound({required this.cacheFile});

  @override
  List<Object> get props => [cacheFile];
}
