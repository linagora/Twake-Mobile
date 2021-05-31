import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/companies_repository.dart';

import 'companies_state.dart';

class CompaniesCubit extends Cubit<CompaniesState> {
  final CompanyRepository repository;

  CompaniesCubit(this.repository) : super(CompaniesInitial());

  Future<void> fetch() async {
    emit(CompaniesLoadInProgress());
    final streamCompanies = repository.fetch();

    await for (var companies in streamCompanies) {
      Company? selected;

      if (Globals.instance.companyId != null) {
        selected =
            companies.firstWhere((c) => c.id == Globals.instance.companyId);
      }

      emit(CompaniesLoadSuccess(companies: companies, selected: selected));
    }
  }

  void selectCompany({required Company company}) {
    Globals.instance.companyIdSet = company.id;
    final companies = (state as CompaniesLoadSuccess).companies;

    emit(CompaniesLoadSuccess(
      companies: companies,
      selected: company,
    ));
  }
}
