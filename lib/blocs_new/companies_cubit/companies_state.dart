import 'package:equatable/equatable.dart';
import 'package:twake/models/company/company.dart';

abstract class CompaniesState extends Equatable {
  const CompaniesState();
}

class CompaniesInitial extends CompaniesState {
  @override
  List<Object> get props => [];
}

class CompaniesLoadSuccess extends CompaniesState {
  final List<Company> companies;

  const CompaniesLoadSuccess({
    required this.companies,
  });
  @override
  List<Object> get props => [companies];
}

class CompaniesLoadInProgress extends CompaniesState {
  const CompaniesLoadInProgress();
  @override
  List<Object> get props => [];
}
