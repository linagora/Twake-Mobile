import 'package:equatable/equatable.dart';
import 'package:twake/models/company/company.dart';

abstract class CompaniesState extends Equatable {
  const CompaniesState();
}

class CompaniesInitial extends CompaniesState {
  @override
  List<Object?> get props => [];
}

class CompaniesLoadSuccess extends CompaniesState {
  final List<Company> companies;
  final String? selectedCompanyId;

  const CompaniesLoadSuccess({
    required this.companies,
    this.selectedCompanyId
  });
  @override
  List<Object?> get props => [companies];
}

class CompaniesLoading extends CompaniesState {
  const CompaniesLoading();
  @override
  List<Object> get props => [];
}

class CompaniesEmpty extends CompaniesState {
  const CompaniesEmpty();
  @override
  List<Object> get props => [];
}
