import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/companies_bloc.dart';
import 'package:twake/events/workspace_event.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/states/company_state.dart';
import 'package:twake/states/workspace_state.dart';

export 'package:twake/events/workspace_event.dart';
export 'package:twake/states/workspace_state.dart';

class WorkspacesBloc extends Bloc<WorkspacesEvent, WorkspaceState> {
  final CollectionRepository<Workspace> repository;
  final CompaniesBloc companiesBloc;
  StreamSubscription subscription;
  String selectedCompanyId;

  WorkspacesBloc({this.repository, this.companiesBloc})
      : super(WorkspacesLoaded(
          workspaces: repository.items,
          selected: repository.selected,
        )) {
    subscription = companiesBloc.listen((CompaniesState state) {
      if (state is CompaniesLoaded) {
        selectedCompanyId = state.selected.id;
        repository.logger.d(
            'Company selected: ${state.selected.name}\nID: ${state.selected.id}');
        this.add(ReloadWorkspaces(selectedCompanyId));
      }
    });
    selectedCompanyId = companiesBloc.repository.selected.id;
  }

  @override
  Stream<WorkspaceState> mapEventToState(WorkspacesEvent event) async* {
    if (event is ReloadWorkspaces) {
      yield WorkspacesLoading();
      await repository.reload(
        filters: [
          ['company_id', '=', event.companyId]
        ],
        queryParams: {'company_id': event.companyId},
        sortFields: {'name': true},
      );
      yield WorkspacesLoaded(
        workspaces: repository.items,
        selected: repository.selected,
      );
    } else if (event is ClearWorkspaces) {
      await repository.clean();
      yield WorkspacesEmpty();
    } else if (event is ChangeSelectedWorkspace) {
      repository.select(event.workspaceId);
      yield WorkspacesLoaded(
        workspaces: repository.items,
        selected: repository.selected,
      );
    } else if (event is LoadSingleWorkspace) {
      // TODO implement single company loading
      throw 'Not implemented yet';
    } else if (event is RemoveWorkspace) {
      throw 'Not implemented yet';
      // yield WorkspacesLoaded(
      // workspaces: repository.items,
      // selected: selected,
      // );
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
