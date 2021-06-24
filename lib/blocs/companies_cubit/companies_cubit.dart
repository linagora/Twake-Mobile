import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/repositories/companies_repository.dart';

import 'companies_state.dart';

class CompaniesCubit extends Cubit<CompaniesState> {
  late final CompaniesRepository _repository;

  CompaniesCubit({CompaniesRepository? repository})
      : super(CompaniesInitial()) {
    if (repository == null) {
      repository = CompaniesRepository();
    }
    _repository = repository;
  }

  Future<void> fetch() async {
    emit(CompaniesLoadInProgress());
    final streamCompanies = _repository.fetch();

    await for (var companies in streamCompanies) {
      Company? selected;

      if (Globals.instance.companyId != null) {
        selected =
            companies.firstWhere((c) => c.id == Globals.instance.companyId);
      }
      emit(CompaniesLoadSuccess(companies: companies, selected: selected!));
    }
  }

  void selectCompany({required String companyId}) {
    emit(CompaniesSwitchInProgress(selectedCompanyId: companyId));

    Globals.instance.companyIdSet = companyId;

    // if (state is CompaniesSuccessState) {
    //   companies = (state as CompaniesLoadSuccess).companies;
    // }
    //
    // if (companies.isEmpty) {
    //   Logger().w('Error: companies list is empty.');
    // } else {
    //   final selected = companies.firstWhere((c) => c.id == companyId, orElse: () {
    //     Logger().e('Error: no corresponding company found.\nThe first available will be picked.');
    //     return companies.first;
    //   },);
    //
    //
    emit(CompaniesSwitchSuccess(companyId: companyId));
    // }
  }

  void selectWorkspace({required String workspaceId}) {
    if (state is! CompaniesLoadSuccess) return;

    final selected = (state as CompaniesLoadSuccess).selected;

    selected.selectedWorkspace = workspaceId;

    _repository.saveOne(company: selected);
  }

  Company? getSelectedCompany() {
    if (state is CompaniesLoadSuccess) {
      return (state as CompaniesLoadSuccess).selected;
    }
    return null;
  }
}
