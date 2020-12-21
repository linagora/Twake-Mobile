import 'package:equatable/equatable.dart';
import 'package:twake/models/company.dart';

abstract class CompaniesState extends Equatable {
  const CompaniesState();
}

class CompaniesLoaded extends CompaniesState {
  final List<Company> companies;

  const CompaniesLoaded({
    this.companies,
  });
  @override
  // TODO: implement props
  List<Object> get props => [companies];
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
