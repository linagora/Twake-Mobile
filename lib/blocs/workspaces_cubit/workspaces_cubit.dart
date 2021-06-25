import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/repositories/workspaces_repository.dart';
import 'package:twake/services/service_bundle.dart';

class WorkspacesCubit extends Cubit<WorkspacesState> {
  late final WorkspacesRepository _repository;

  WorkspacesCubit({WorkspacesRepository? repository})
      : super(WorkspacesInitial()) {
    if (repository == null) {
      repository = WorkspacesRepository();
    }
    _repository = repository;

    // wait for authentication check before attempting to subscribe
    Future.delayed(
      Duration(seconds: 7),
      SynchronizationService.instance.subscribeToBadges,
    );
  }

  Future<void> fetch({String? companyId, String? selectedId}) async {
    emit(WorkspacesLoadInProgress());
    final stream = _repository.fetch(companyId: companyId);

    selectedId = selectedId ?? Globals.instance.workspaceId;

    await for (var workspaces in stream) {
      Workspace? selected;

      if (selectedId != null) {
        selected = workspaces.firstWhere((w) => w.id == selectedId);
      } else {
        selected = workspaces.first;
      }

      Globals.instance.workspaceIdSet = selected.id;

      emit(WorkspacesLoadSuccess(workspaces: workspaces, selected: selected));
    }
  }

  Future<void> createWorkspace({
    String? companyId,
    required String name,
    List<String>? members,
  }) async {
    final workspace = await _repository.createWorkspace(
        companyId: companyId, name: name, members: members);

    final workspaces = (state as WorkspacesLoadSuccess).workspaces;

    workspaces.add(workspace);

    emit(WorkspacesLoadSuccess(workspaces: workspaces, selected: workspace));
  }

  Future<List<Account>> fetchMembers({String? workspaceId}) async {
    final members = await _repository.fetchMembers(workspaceId: workspaceId);

    return members;
  }

  void selectWorkspace({required String workspaceId}) {
    Globals.instance.workspaceIdSet = workspaceId;

    // Subscribe to socketIO updates
    SynchronizationService.instance.subscribeForChannels();

    final workspaces = (state as WorkspacesLoadSuccess).workspaces;

    emit(WorkspacesLoadSuccess(
      workspaces: workspaces,
      selected: workspaces.firstWhere((w) => w.id == workspaceId),
    ));
  }
}
