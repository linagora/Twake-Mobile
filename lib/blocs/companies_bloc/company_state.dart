import 'package:equatable/equatable.dart';
import 'package:twake/models/company.dart';

abstract class CompaniesState extends Equatable {
  const CompaniesState();
}

class CompaniesLoaded extends CompaniesState {
  final List<Company> companies;
  final Company selected;
  const CompaniesLoaded({
    this.companies,
    this.selected,
  });
  @override
  List<Object> get props => [companies, selected];
}

class CompanyLoaded extends CompaniesState {
  final Company company;
  const CompanyLoaded({this.company});
  @override
  List<Object> get props => [company];
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
