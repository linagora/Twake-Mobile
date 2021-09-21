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

    Future.delayed(Duration(seconds: 5), () {
      if (Globals.instance.token != null) {
        fetchMembers();
      }
    });
  }

  Future<void> fetch({
    String? companyId,
    String? selectedId,
    bool localOnly: false,
  }) async {
    emit(WorkspacesLoadInProgress());

    final stream = _repository.fetch(
      companyId: companyId,
      localOnly: localOnly,
    );

    if (selectedId != null) {
      Globals.instance.workspaceIdSet = selectedId;
      SynchronizationService.instance.subscribeForChannels(
        companyId: Globals.instance.companyId!,
        workspaceId: selectedId,
      );
    }

    selectedId = selectedId ?? Globals.instance.workspaceId;

    await for (var workspaces in stream) {
      // if user switched company before the fetch method is complete, abort
      if (companyId != Globals.instance.companyId) break;

      Workspace? selected;

      if (state is WorkspacesLoadSuccess) {
        selected = (state as WorkspacesLoadSuccess).selected;
      } else if (selectedId != null &&
          workspaces.any((w) => w.id == selectedId)) {
        selected = workspaces.firstWhere((w) => w.id == selectedId);
      } else {
        selected = workspaces.first;
      }

      if (selected != null) {
        Globals.instance.workspaceIdSet = selected.id;
      }

      emit(WorkspacesLoadSuccess(workspaces: workspaces, selected: selected));
    }
  }

  Future<void> createWorkspace({
    String? companyId,
    required String name,
    List<String>? members,
  }) async {
    final workspace = await _repository.create(
        companyId: companyId, name: name, members: members);

    final workspaces = (state as WorkspacesLoadSuccess).workspaces;

    workspaces.add(workspace);

    selectWorkspace(workspaceId: workspace.id);
  }

  Future<List<Account>> fetchMembers(
      {String? workspaceId, bool local: false}) async {
    final members = await _repository.fetchMembers(
      workspaceId: workspaceId,
      local: local,
    );

    return members;
  }

  void selectWorkspace({required String workspaceId}) {
    Globals.instance.workspaceIdSet = workspaceId;

    final workspaces = (state as WorkspacesLoadSuccess).workspaces;
    _repository.fetchMembers();

    emit(WorkspacesLoadSuccess(
      workspaces: workspaces,
      selected: workspaces.firstWhere((w) => w.id == workspaceId),
    ));
    // Subscribe to socketIO updates
    SynchronizationService.instance.subscribeForChannels(
      companyId: Globals.instance.companyId!,
      workspaceId: workspaceId,
    );
  }
}
