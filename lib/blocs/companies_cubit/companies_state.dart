import 'package:equatable/equatable.dart';
import 'package:twake/models/company/company.dart';

export 'package:twake/models/company/company.dart';

abstract class CompaniesState extends Equatable {
  const CompaniesState();
}

class CompaniesInitial extends CompaniesState {
  const CompaniesInitial();

  @override
  List<Object> get props => [];
}

class CompaniesLoadSuccess extends CompaniesState {
  final List<Company> companies;
  final Company selected;

  const CompaniesLoadSuccess({required this.companies, required this.selected});

  @override
  List<Object> get props => [companies, selected];
}

class CompaniesLoadInProgress extends CompaniesState {
  const CompaniesLoadInProgress();

  @override
  List<Object> get props => [];
}
