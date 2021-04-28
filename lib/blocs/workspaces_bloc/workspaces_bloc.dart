import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/companies_bloc/companies_bloc.dart';
import 'package:twake/blocs/notification_bloc/notification_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/workspaces_bloc/workspace_event.dart';
import 'package:twake/blocs/companies_bloc/company_state.dart';
import 'package:twake/blocs/workspaces_bloc/workspace_state.dart';
import 'package:twake/repositories/workspaces_repository.dart';

export 'package:twake/blocs/workspaces_bloc/workspace_event.dart';
export 'package:twake/blocs/workspaces_bloc/workspace_state.dart';

class WorkspacesBloc extends Bloc<WorkspacesEvent, WorkspaceState> {
  final WorkspacesRepository repository;
  final CompaniesBloc companiesBloc;
  StreamSubscription subscription;
  String selectedCompanyId;
  final NotificationBloc notificationBloc;
  StreamSubscription _notificationSubscription;

  WorkspacesBloc({
    this.repository,
    this.companiesBloc,
    this.notificationBloc,
  }) : super(WorkspacesLoaded(
          workspaces: repository.items,
          selected: repository.selected,
        )) {
    subscription = companiesBloc.listen((CompaniesState state) {
      if (state is CompaniesLoaded) {
        selectedCompanyId = state.selected.id;
        repository.logger.e(
            'Company selected: ${state.selected.name}\nID: ${state.selected.id}');
        this.add(ReloadWorkspaces(selectedCompanyId, forceFromApi: true));
      }
    });
    _notificationSubscription =
        notificationBloc.listen((NotificationState state) async {
      if (state is BaseChannelMessageNotification &&
          state.data.workspaceId != 'direct') {
        while (true) {
          if (companiesBloc.state is CompaniesLoaded &&
              (companiesBloc.state as CompaniesLoaded).selected.id ==
                  state.data.companyId) {
            this.add(ChangeSelectedWorkspace(state.data.workspaceId));
            break;
          } else {
            // print('WAITING FOR COMPANY SELECTION');
            await Future.delayed(Duration(milliseconds: 500));
          }
        }
      }
    });
    ProfileBloc.selectedWorkspaceId = repository.selected.id;
    selectedCompanyId = companiesBloc.repository.selected.id;
    // for future use in mentions
    repository.fetchMembers();
  }

  @override
  Stream<WorkspaceState> mapEventToState(WorkspacesEvent event) async* {
    if (event is ReloadWorkspaces) {
      yield WorkspacesLoading(companyId: event.companyId);
      print('NEW COMPANY ID: ${event.companyId}');
      await repository.reload(
        filters: [
          ['company_id', '=', event.companyId]
        ],
        queryParams: {'company_id': event.companyId},
        sortFields: {'name': true},
        forceFromApi: event.forceFromApi,
      );
      print('Selected: ${repository.selected.companyId}');

      final newState = WorkspacesLoaded(
        workspaces: repository.items,
        selected: repository.selected,
      );
      repository.logger
          .w("YIELDING NEW WORKSPACES STATE: ${this.state != newState}");
      yield newState;
    } else if (event is CheckForChange) {
      // Sorry Pavel, but cannot block the stream here with await
      repository.didChange(
        filters: [
          ['company_id', '=', event.companyId]
        ],
        queryParams: {'company_id': event.companyId},
      ).then((changed) {
        if (changed) this.add(ForceRefresh());
      });
    } else if (event is ForceRefresh) {
      repository.items.sort((w1, w2) => w1.name.compareTo(w2.name));
      yield WorkspacesLoaded(
        workspaces: repository.items,
        selected: repository.selected,
        force: DateTime.now().toString(),
      );
    } else if (event is ClearWorkspaces) {
      await repository.clean();
      yield WorkspacesEmpty();
    } else if (event is ChangeSelectedWorkspace) {
      // print('Workspace id to select: ${event.workspaceId}');
      repository.select(event.workspaceId);
      ProfileBloc.selectedWorkspaceId = event.workspaceId;
      // repository.logger.w("YIELDING NEW WORKSPACES STATE");
      yield WorkspaceSelected(
        workspaces: repository.items,
        selected: repository.selected,
      );
      repository.fetchMembers();
    } else if (event is LoadSingleWorkspace) {
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
    _notificationSubscription.cancel();
    return super.close();
  }
}
