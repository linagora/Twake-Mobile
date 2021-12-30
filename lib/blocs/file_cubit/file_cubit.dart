import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/repositories/file_repository.dart';
import 'package:twake/blocs/file_cubit/file_state.dart';

class FileCubit extends Cubit<FileState> {
  late final FileRepository _repository;

  FileCubit({FileRepository? repository}) : super(FileInitial()) {
    if (repository == null) {
      repository = FileRepository();
    }
    _repository = repository;
  }

  Future<File?> getFileData({required String id}) async {
    try {
      final file = await _repository.getFileData(id: id);
      return file;
    } catch (e) {
      Logger().e('Error occurred during retrieving file metadata:\n$e');
      return null;
    }
  }

}
