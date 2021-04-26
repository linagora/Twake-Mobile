import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/companies_bloc/company_event.dart';
import 'package:twake/models/company.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/blocs/companies_bloc/company_state.dart';

export 'package:twake/blocs/companies_bloc/company_event.dart';
export 'package:twake/blocs/companies_bloc/company_state.dart';

class CompaniesBloc extends Bloc<CompaniesEvent, CompaniesState> {
  final CollectionRepository<Company> repository;
  final NotificationBloc notificationBloc;
  StreamSubscription _notificationSubscription;

  CompaniesBloc(this.repository, this.notificationBloc)
      : super(CompaniesLoaded(
          companies: repository.items,
          selected: repository.selected,
        )) {
    // repository.logger.w('SELECTED COMPANY: ${repository.selected.id}');
    ProfileBloc.selectedCompanyId = repository.selected.id;
    ProfileBloc.selectedCompany = repository.selected;

    _notificationSubscription =
        notificationBloc.listen((NotificationState state) {
      if (state is BaseChannelMessageNotification) {
        this.add(ChangeSelectedCompany(state.data.companyId));
      }
    });
  }

  @override
  Stream<CompaniesState> mapEventToState(CompaniesEvent event) async* {
    if (event is ReloadCompanies) {
      await repository.reload();
      yield CompaniesLoaded(
        companies: repository.items,
        selected: repository.selected,
      );
    } else if (event is ClearCompanies) {
      await repository.clean();
      yield CompaniesEmpty();
    } else if (event is ChangeSelectedCompany) {
      repository.select(event.companyId);
      ProfileBloc.selectedCompanyId = event.companyId;
      final newState = CompaniesLoaded(
        companies: repository.items,
        selected: repository.selected,
      );
      // repository.ogger
      // .w("YIELDING NEW COMPANY STATE: ${this.state != newState}");
      yield newState;
    } else if (event is LoadSingleCompany) {
      throw 'Not implemented yet';
    } else if (event is RemoveCompany) {
      throw 'Not implemented yet';
      // repository.items.removeWhere((i) => i.id == event.companyId);
      //
      // yield CompaniesLoaded(
      // companies: repository.items,
      // selected: selected,
      // );
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription.cancel();
    return super.close();
  }
}
