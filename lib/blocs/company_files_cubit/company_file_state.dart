part of 'company_file_cubit.dart';

enum CompanyFileStatus { init, loading, done, failed, empty }

class CompanyFileState extends Equatable {
  final CompanyFileStatus companyFileStatus;
  final List<MessageFile> files;

  const CompanyFileState({
    this.companyFileStatus = CompanyFileStatus.init,
    required this.files,
  });

  CompanyFileState copyWith({
    CompanyFileStatus? newCompanyFileStatus,
    List<MessageFile>? newFiles,
  }) {
    return CompanyFileState(
        files: newFiles ?? this.files,
        companyFileStatus: newCompanyFileStatus ?? this.companyFileStatus);
  }

  @override
  List<Object?> get props => [
        companyFileStatus,
      ];
}
