part of 'company_file_cubit.dart';

enum CompanyFileStatus { init, loading, done, failed }

class CompanyFileState extends Equatable {
  final CompanyFileStatus companyFileStatus;
  final List<ChannelFile> files;

  const CompanyFileState({
    this.companyFileStatus = CompanyFileStatus.init,
    required this.files,
  });

  CompanyFileState copyWith({
    CompanyFileStatus? newCompanyFileStatus,
    List<ChannelFile>? newFiles,
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
