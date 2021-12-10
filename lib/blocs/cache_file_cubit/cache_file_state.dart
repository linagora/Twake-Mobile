part of 'cache_file_cubit.dart';

class CacheFileState extends Equatable {
  final List<File> fileList;

  const CacheFileState({required this.fileList});

  CacheFileState copyWith({List<File>? newList}) {
    return CacheFileState(fileList: newList ?? this.fileList);
  }

  @override
  List<Object> get props => [fileList];
}
