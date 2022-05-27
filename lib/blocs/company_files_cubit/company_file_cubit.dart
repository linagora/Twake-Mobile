import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/models/channel/channel_file.dart';
import 'package:twake/repositories/file_repository.dart';

part 'company_file_state.dart';

class CompanyFileCubit extends Cubit<CompanyFileState> {
  final AccountCubit accountCubit;
  late final FileRepository _repository;

  CompanyFileCubit({required this.accountCubit, FileRepository? repository})
      : super(CompanyFileState(
            companyFileStatus: CompanyFileStatus.init, files: [])) {
    _repository = repository ?? FileRepository();
  }

  void getCompanyFiles() async {
    emit(state.copyWith(newCompanyFileStatus: CompanyFileStatus.loading));

    var userName = 'unknown';
    final accountState = accountCubit.state;
    if (accountState is AccountLoadSuccess) {
      userName = accountState.account.fullName;
    }

    final files =
        await _repository.fetchUserFilesFromCompany(userName: userName);

    emit(state.copyWith(
        newCompanyFileStatus: CompanyFileStatus.done, newFiles: files));
  }
}
