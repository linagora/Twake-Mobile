import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/repositories/file_repository.dart';

part 'company_file_state.dart';

class CompanyFileCubit extends Cubit<CompanyFileState> {
  late final FileRepository _repository;

  CompanyFileCubit({FileRepository? repository})
      : super(CompanyFileState(
            companyFileStatus: CompanyFileStatus.init, files: [])) {
    _repository = repository ?? FileRepository();
  }

  void getCompanyFiles() async {
    emit(state.copyWith(newCompanyFileStatus: CompanyFileStatus.loading));
    final files = await _repository.fetchUserFilesFromCompany();
    emit(state.copyWith(
        newCompanyFileStatus: CompanyFileStatus.done, newFiles: files));
  }
}
