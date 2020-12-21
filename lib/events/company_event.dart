import 'package:equatable/equatable.dart';

abstract class CompaniesEvent extends Equatable {
  const CompaniesEvent();
}

class LoadCompanies extends CompaniesEvent {
  const LoadCompanies();
  @override
  List<Object> get props => [];
}

class ClearCompanies extends CompaniesEvent {
  const ClearCompanies();
  @override
  List<Object> get props => [];
}

class LoadSingleCompany extends CompaniesEvent {
  final String companyId;
  LoadSingleCompany(this.companyId);

  @override
  List<Object> get props => [companyId];
}

class ChangeSelectedCompany extends CompaniesEvent {
  final String companyId;
  ChangeSelectedCompany(this.companyId);

  @override
  List<Object> get props => [companyId];
}
