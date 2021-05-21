import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/company_repository.dart';

import 'company_state.dart';

class CompaniesCubit extends Cubit<CompaniesState> {
  final CompanyRepository repository;
  List<Company> _companies = [];

  CompaniesCubit(this.repository) : super(CompaniesInitial());

  Future<void> fetch() async {
    emit(CompaniesLoading());
    final companies = await repository.fetchCompanies();
    _companies = companies;
    emit(CompaniesLoadSuccess(
      companies: companies,
      selectedCompanyId: Globals.instance.companyId,
    ));
  }

  Future<void> clear() async {
    emit(CompaniesEmpty());
  }

  void selectCompany(String companyId) {
    Globals.instance.companyIdSet = companyId;
    final newState = CompaniesLoadSuccess(
      companies: _companies,
      selectedCompanyId: companyId,
    );
    emit(newState);
  }
}
