part of 'cache_file_cubit.dart';

abstract class CacheFileState extends Equatable {
  const CacheFileState();

  @override
  List<Object> get props => [];
}

class CacheFilesInitial extends CacheFileState {
  final List<File> fileList;

  const CacheFilesInitial({required this.fileList});

  @override
  List<Object> get props => [fileList];
}

class CacheFileNotFoun extends CacheFileState {
  const CacheFileNotFoun();
  @override
  List<Object> get props => [];
}

class CacheFileFound extends CacheFileState {
  final File cacheFile;

  const CacheFileFound({required this.cacheFile});

  @override
  List<Object> get props => [cacheFile];
}
