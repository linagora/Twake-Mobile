part of 'file_cubit.dart';

abstract class FileState extends Equatable {
  const FileState();
}

class FileInitial extends FileState {
  @override
  List<Object> get props => [];
}
