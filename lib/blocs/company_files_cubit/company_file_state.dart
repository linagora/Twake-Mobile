part of 'company_file_cubit.dart';

class CompanyFileInitial extends CompanyFileState {}

enum CompanyFileStatus { init, loading, done, failed }

class CompanyFileState extends Equatable {
  final CompanyFileStatus companyFileStatus;

  const CompanyFileState({
    this.companyFileStatus = CompanyFileStatus.init,
  });

  CompanyFileState copyWith({
    CompanyFileStatus? newCompanyFileStatus,
  }) {
    return CompanyFileState(
        companyFileStatus: newCompanyFileStatus ?? this.companyFileStatus);
  }

  @override
  List<Object?> get props => [
        companyFileStatus,
      ];
}
