import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'company_file_state.dart';

class CompanyFileCubit extends Cubit<CompanyFileState> {
  CompanyFileCubit()
      : super(CompanyFileState(companyFileStatus: CompanyFileStatus.init));

  void getCompanyFiles() async {
    // Add company files when the api is ready
    emit(CompanyFileState(companyFileStatus: CompanyFileStatus.loading));
    await Future.delayed(Duration(seconds: 1));
    emit(CompanyFileState(companyFileStatus: CompanyFileStatus.done));
  }
}
